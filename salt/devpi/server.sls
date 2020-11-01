include:
  - devpi.client
  - devpi.strictyaml
  - devpi.web
  - python3.appdirs
  - python3.argon2
  - python3.attr
  - python3.execnet
  - python3.itsdangerous
  - python3.passlib
  - python3.pluggy
  - python3.pyramid
  - python3.py
  - python3.repoze-lru
  - python3.waitress

{% set json_info = pillar['devpi']['packages']['devpi-json-info'] %}
{% set server = pillar['devpi']['packages']['devpi-server'] %}

{% if not salt['file.directory_exists'](pillar['devpi']['virtualenv']) or salt['cmd.run'](salt['file.join'](pillar['devpi']['virtualenv'], 'bin', 'python3') + ' -c "import pkg_resources; print(pkg_resources.get_distribution(\\"devpi-server\\").version)"') != server['version'] %}
install-devpi-server-package:
  file.managed:
    - name:  {{ salt['file.join'](pillar['devpi']['tmpdir'], 'server', salt['file.basename'](server['source'])) }}
    - source: {{ server['source'] }}
    - source_hash: {{ server['hash'] }}
    - keep_source: False
    - user: {{ pillar['devpi']['user'] }}
    - group: {{ pillar['devpi']['group'] }}
    - mode: 0644
    - makedirs: True
    - skip_verify: False

  archive.extracted:
    - name: {{ salt['file.join'](pillar['devpi']['tmpdir'], 'server') }}
    - source:  {{ salt['file.join'](pillar['devpi']['tmpdir'], 'server', salt['file.basename'](server['source'])) }}
    - clean: True
    - user: {{ pillar['devpi']['user'] }}
    - group: {{ pillar['devpi']['group'] }}

  cmd.run:
    - name: "{{ salt['file.join'](pillar['devpi']['virtualenv'], 'bin', 'pip3') }} install --compile --no-deps {{ salt['file.join'](pillar['devpi']['tmpdir'], 'server', 'devpi-server-' + server['version']) }}; rm -rfv {{ salt['file.join'](pillar['devpi']['tmpdir'], 'server') }}"
    - cwd: {{ pillar['devpi']['virtualenv'] }}
    - runas: {{ pillar['devpi']['user'] }}
    - prepend_path: {{ salt['file.join'](pillar['devpi']['virtualenv'], 'bin') }}
    - watch_in:
      - service: manage-devpi-server
{% endif %}

{% if not salt['file.directory_exists'](pillar['devpi']['virtualenv']) or salt['cmd.run'](salt['file.join'](pillar['devpi']['virtualenv'], 'bin', 'python3') + ' -c "import pkg_resources; print(pkg_resources.get_distribution(\\"devpi_json_info\\").version)"') != json_info['version'] %}
install-devpi-json-info-package:
  file.managed:
    - name:  {{ salt['file.join'](pillar['devpi']['tmpdir'], 'json-info', salt['file.basename'](json_info['source'])) }}
    - source: {{ json_info['source'] }}
    - source_hash: {{ json_info['hash'] }}
    - keep_source: False
    - user: {{ pillar['devpi']['user'] }}
    - group: {{ pillar['devpi']['group'] }}
    - mode: 0644
    - makedirs: True
    - skip_verify: False

  archive.extracted:
    - name: {{ salt['file.join'](pillar['devpi']['tmpdir'], 'json-info') }}
    - source:  {{ salt['file.join'](pillar['devpi']['tmpdir'], 'json-info', salt['file.basename'](json_info['source'])) }}
    - clean: True
    - user: {{ pillar['devpi']['user'] }}
    - group: {{ pillar['devpi']['group'] }}

  cmd.run:
    - name: "{{ salt['file.join'](pillar['devpi']['virtualenv'], 'bin', 'pip3') }} install --compile --no-deps {{ salt['file.join'](pillar['devpi']['tmpdir'], 'json-info', 'devpi-json-info-' + json_info['version']) }}; rm -rfv {{ salt['file.join'](pillar['devpi']['tmpdir'], 'json-info') }}"
    - cwd: {{ pillar['devpi']['virtualenv'] }}
    - runas: {{ pillar['devpi']['user'] }}
    - prepend_path: {{ salt['file.join'](pillar['devpi']['virtualenv'], 'bin') }}
    - watch_in:
      - service: manage-devpi-server
{% endif %}

{% for util in ['clear-search-index', 'export', 'fsck', 'gen-config', 'import', 'init', 'passwd', 'server'] %}
symlink-devpi-server-{{ 'binary' if util == 'server' else util }}:
  file.symlink:
    - name: /usr/local/bin/devpi-{{ util }}
    - target: {{ salt['file.join'](pillar['devpi']['virtualenv'], 'bin', 'devpi-' + util) }}
    - force: True
    - user: root
    - group: root
    - mode: 0755
{% endfor %}

{% if not salt['file.directory_exists'](pillar['devpi']['server']['serverdir']) %}
initialize-devpi-serverdir:
  cmd.run:
    - name: {{ salt['file.join'](pillar['devpi']['virtualenv'], 'bin', 'devpi-init') }} --role {{ pillar['devpi']['server']['role'] }} --serverdir {{ pillar['devpi']['server']['serverdir'] }} --storage {{ pillar['devpi']['server']['storage'] }} --no-root-pypi --root-passwd-hash '{{ salt['cmd.run'](pillar['devpi']['python3'] + ' -c "import py; from passlib.context import CryptContext; print(py.builtin._totext(CryptContext(schemes=[\\"argon2\\"], deprecated=\\"auto\\").hash(\\"' + pillar['devpi']['users']['root']['password'] + '\\")))"') }}'
    - runas: {{ pillar['devpi']['user'] }}
    - watch_in:
      - service: manage-devpi-server
{% endif %}

manage-devpi-server:
  file.managed:
    - name: /etc/systemd/system/devpi-server.service
    - source: salt://devpi/systemd/devpi-server.service.jinja
    - template: jinja
    - user: root
    - group: root
    - mode: 0644

  module.run:
    - name: service.systemctl_reload
    - onchanges:
      - file: manage-devpi-server

  service.running:
    - name: devpi-server
    - enable: True
    - restart: True
    - watch:
      - file: manage-devpi-server

  cmd.run:
    - name: "/bin/sh -c '/bin/false; while [ $? -ne 0 ]; do sleep 1; curl -s --fail --unix-socket /var/run/devpi/devpi.sock http://localhost >/dev/null; done'"
    - onchanges:
      - service: manage-devpi-server

{# Manage the nginx site for this server. #}
manage-nginx-devpi-site:
  file.managed:
    - name: /etc/nginx/sites.d/devpi.conf
    - source: salt://devpi/nginx/devpi.conf.jinja
    - template: jinja
    - user: root
    - group: root
    - mode: 0644

  service.running:
    - name: nginx
    - reload: True
    - watch:
      - file: manage-nginx-devpi-site
