include:
  - devpi.common
  - python3.check-manifest
  - python3.pkginfo
  - python3.pluggy
  - python3.py
  - python3.tox

{% set client = pillar['devpi']['packages']['client'] %}

{% if salt['cmd.run'](salt['file.join'](pillar['devpi']['virtualenv'], 'bin', 'python3') + ' -c "import pkg_resources; print(pkg_resources.get_distribution(\\"devpi-client\\").version)"') != client['version'] %}
install-devpi-client-package:
  file.managed:
    - name:  {{ salt['file.join'](pillar['devpi']['tmpdir'], 'client', salt['file.basename'](client['source'])) }}
    - source: {{ client['source'] }}
    - source_hash: {{ client['hash'] }}
    - keep_source: False
    - user: {{ pillar['devpi']['user'] }}
    - group: {{ pillar['devpi']['group'] }}
    - mode: 0644
    - makedirs: True
    - skip_verify: False

  archive.extracted:
    - name: {{ salt['file.join'](pillar['devpi']['tmpdir'], 'client') }}
    - source:  {{ salt['file.join'](pillar['devpi']['tmpdir'], 'client', salt['file.basename'](client['source'])) }}
    - clean: True
    - user: {{ pillar['devpi']['user'] }}
    - group: {{ pillar['devpi']['group'] }}

  cmd.run:
    - name: "{{ salt['file.join'](pillar['devpi']['virtualenv'], 'bin', 'pip3') }} install --compile --no-deps {{ salt['file.join'](pillar['devpi']['tmpdir'], 'client', 'devpi-client-' + client['version']) }}; rm -rfv {{ salt['file.join'](pillar['devpi']['tmpdir'], 'client') }}"
    - cwd: {{ pillar['devpi']['virtualenv'] }}
    - runas: {{ pillar['devpi']['user'] }}
    - prepend_path: {{ salt['file.join'](pillar['devpi']['virtualenv'], 'bin') }}
{% endif %}

symlink-devpi-client:
  file.symlink:
    - name: /usr/local/bin/devpi
    - target: {{ salt['file.join'](pillar['devpi']['virtualenv'], 'bin', 'devpi') }}
    - force: True
    - user: root
    - group: root
    - mode: 0755
