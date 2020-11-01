include:
  - devpi.common
  - python3.bs4
  - python3.chameleon
  - python3.defusedxml
  - python3.docutils
  - python3.pygments
  - python3.pyramid
  - python3.readme-renderer
  - python3.whoosh

{% set web = pillar['devpi']['packages']['devpi-web'] %}

{% if not salt['file.directory_exists'](pillar['devpi']['virtualenv']) or salt['cmd.run'](salt['file.join'](pillar['devpi']['virtualenv'], 'bin', 'python3') + ' -c "import pkg_resources; print(pkg_resources.get_distribution(\\"devpi-web\\").version)"') != web['version'] %}
install-devpi-web-package:
  file.managed:
    - name:  {{ salt['file.join'](pillar['devpi']['tmpdir'], 'web', salt['file.basename'](web['source'])) }}
    - source: {{ web['source'] }}
    - source_hash: {{ web['hash'] }}
    - keep_source: False
    - user: {{ pillar['devpi']['user'] }}
    - group: {{ pillar['devpi']['group'] }}
    - mode: 0644
    - makedirs: True
    - skip_verify: False

  archive.extracted:
    - name: {{ salt['file.join'](pillar['devpi']['tmpdir'], 'web') }}
    - source:  {{ salt['file.join'](pillar['devpi']['tmpdir'], 'web', salt['file.basename'](web['source'])) }}
    - clean: True
    - user: {{ pillar['devpi']['user'] }}
    - group: {{ pillar['devpi']['group'] }}

  cmd.run:
    - name: "{{ salt['file.join'](pillar['devpi']['virtualenv'], 'bin', 'pip3') }} install --compile --no-deps {{ salt['file.join'](pillar['devpi']['tmpdir'], 'web', 'devpi-web-' + web['version']) }}; rm -rfv {{ salt['file.join'](pillar['devpi']['tmpdir'], 'web') }}"
    - cwd: {{ pillar['devpi']['virtualenv'] }}
    - runas: {{ pillar['devpi']['user'] }}
    - prepend_path: {{ salt['file.join'](pillar['devpi']['virtualenv'], 'bin') }}
{% endif %}
