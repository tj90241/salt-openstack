{% if not salt['file.file_exists']('/usr/local/bin/consul') or
      salt['file.stats']('/usr/local/bin/consul').get('mode', '') | int != 755 %}
{% set version = {} %}
{% else %}
{% set version = salt['cmd.run']('/usr/local/bin/consul version -format json') | load_json %}
{% endif %}

{% if version.get('Version', '') | lower != pillar['consul']['package']['version'] %}
install-consul-package:
  archive.extracted:
    - name: /tmp/consul-{{ pillar['consul']['package']['version'] }}/contents
    - source: {{ pillar['consul']['package'][grains.cpuarch]['source'] }}
    - source_hash: {{ pillar['consul']['package'][grains.cpuarch]['hash'] }}
    - skip_verify: False
    - keep_source: False
    - force: True
    - overwrite: True
    - clean_parent: True
    - enforce_toplevel: False

  file.managed:
    - name: /usr/local/bin/consul
    - source: /tmp/consul-{{ pillar['consul']['package']['version'] }}/contents/consul
    - user: root
    - group: root
    - mode: 0755
    - watch_in:
      - service: manage-consul

cleanup-consul-package:
  file.absent:
    - name: /tmp/consul-{{ pillar['consul']['package']['version'] }}
{% endif %}

