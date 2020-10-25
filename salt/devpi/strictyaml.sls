include:
  - python3.dateutil
  - python3.ruamel-yaml

{% set strictyaml = pillar['devpi']['packages']['strictyaml'] %}

{% if salt['cmd.run'](salt['file.join'](pillar['devpi']['virtualenv'], 'bin', 'python3') + ' -c "import pkg_resources; print(pkg_resources.get_distribution(\\"strictyaml\\").version)"') != strictyaml['version'] %}
install-devpi-strictyaml-package:
  file.managed:
    - name:  {{ salt['file.join'](pillar['devpi']['tmpdir'], 'strictyaml', salt['file.basename'](strictyaml['source'])) }}
    - source: {{ strictyaml['source'] }}
    - source_hash: {{ strictyaml['hash'] }}
    - keep_source: False
    - user: {{ pillar['devpi']['user'] }}
    - group: {{ pillar['devpi']['group'] }}
    - mode: 0644
    - makedirs: True
    - skip_verify: False

  archive.extracted:
    - name: {{ salt['file.join'](pillar['devpi']['tmpdir'], 'strictyaml') }}
    - source:  {{ salt['file.join'](pillar['devpi']['tmpdir'], 'strictyaml', salt['file.basename'](strictyaml['source'])) }}
    - clean: True
    - user: {{ pillar['devpi']['user'] }}
    - group: {{ pillar['devpi']['group'] }}

  cmd.run:
    - name: "{{ salt['file.join'](pillar['devpi']['virtualenv'], 'bin', 'pip3') }} install --compile --no-deps {{ salt['file.join'](pillar['devpi']['tmpdir'], 'strictyaml', 'strictyaml-' + strictyaml['version']) }}; rm -rfv {{ salt['file.join'](pillar['devpi']['tmpdir'], 'strictyaml') }}"
    - cwd: {{ pillar['devpi']['virtualenv'] }}
    - runas: {{ pillar['devpi']['user'] }}
    - prepend_path: {{ salt['file.join'](pillar['devpi']['virtualenv'], 'bin') }}
{% endif %}
