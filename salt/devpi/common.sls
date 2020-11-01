include:
  - devpi.lazy
  - python3.py
  - python3.requests

{% set common = pillar['devpi']['packages']['devpi-common'] %}

{% if not salt['file.directory_exists'](pillar['devpi']['virtualenv']) or salt['cmd.run'](salt['file.join'](pillar['devpi']['virtualenv'], 'bin', 'python3') + ' -c "import pkg_resources; print(pkg_resources.get_distribution(\\"devpi-common\\").version)"') != common['version'] %}
install-devpi-common-package:
  file.managed:
    - name:  {{ salt['file.join'](pillar['devpi']['tmpdir'], 'common', salt['file.basename'](common['source'])) }}
    - source: {{ common['source'] }}
    - source_hash: {{ common['hash'] }}
    - keep_source: False
    - user: {{ pillar['devpi']['user'] }}
    - group: {{ pillar['devpi']['group'] }}
    - mode: 0644
    - makedirs: True
    - skip_verify: False

  archive.extracted:
    - name: {{ salt['file.join'](pillar['devpi']['tmpdir'], 'common') }}
    - source:  {{ salt['file.join'](pillar['devpi']['tmpdir'], 'common', salt['file.basename'](common['source'])) }}
    - clean: True
    - user: {{ pillar['devpi']['user'] }}
    - group: {{ pillar['devpi']['group'] }}

  cmd.run:
    - name: "{{ salt['file.join'](pillar['devpi']['virtualenv'], 'bin', 'pip3') }} install --compile --no-deps {{ salt['file.join'](pillar['devpi']['tmpdir'], 'common', 'devpi-common-' + common['version']) }}; rm -rfv {{ salt['file.join'](pillar['devpi']['tmpdir'], 'common') }}"
    - cwd: {{ pillar['devpi']['virtualenv'] }}
    - runas: {{ pillar['devpi']['user'] }}
    - prepend_path: {{ salt['file.join'](pillar['devpi']['virtualenv'], 'bin') }}
{% endif %}
