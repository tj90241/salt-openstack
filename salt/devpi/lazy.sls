include:
  - python3.dateutil
  - python3.ruamel-yaml

{% set lazy = pillar['devpi']['packages']['lazy'] %}

{% if salt['cmd.run'](salt['file.join'](pillar['devpi']['virtualenv'], 'bin', 'python3') + ' -c "import pkg_resources; print(pkg_resources.get_distribution(\\"lazy\\").version)"') != lazy['version'] %}
install-devpi-lazy-package:
  file.managed:
    - name:  {{ salt['file.join'](pillar['devpi']['tmpdir'], 'lazy', salt['file.basename'](lazy['source'])) }}
    - source: {{ lazy['source'] }}
    - source_hash: {{ lazy['hash'] }}
    - keep_source: False
    - user: {{ pillar['devpi']['user'] }}
    - group: {{ pillar['devpi']['group'] }}
    - mode: 0644
    - makedirs: True
    - skip_verify: False

  archive.extracted:
    - name: {{ salt['file.join'](pillar['devpi']['tmpdir'], 'lazy') }}
    - source:  {{ salt['file.join'](pillar['devpi']['tmpdir'], 'lazy', salt['file.basename'](lazy['source'])) }}
    - clean: True
    - user: {{ pillar['devpi']['user'] }}
    - group: {{ pillar['devpi']['group'] }}

  cmd.run:
    - name: "{{ salt['file.join'](pillar['devpi']['virtualenv'], 'bin', 'pip3') }} install --compile --no-deps {{ salt['file.join'](pillar['devpi']['tmpdir'], 'lazy', 'lazy-' + lazy['version']) }}; rm -rfv {{ salt['file.join'](pillar['devpi']['tmpdir'], 'lazy') }}"
    - cwd: {{ pillar['devpi']['virtualenv'] }}
    - runas: {{ pillar['devpi']['user'] }}
    - prepend_path: {{ salt['file.join'](pillar['devpi']['virtualenv'], 'bin') }}
{% endif %}
