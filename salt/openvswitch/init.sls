{%- set dpdk = pillar.get('dpdk', {}).get('enabled', False) -%}
manage-openvswitch:
  pkg.installed:
    - name: openvswitch-switch{% if dpdk %}-dpdk{% endif %}
    - refresh: False
    - version: latest

  file.managed:
    - name: /etc/default/openvswitch-switch
    - source: salt://openvswitch/default.jinja
    - template: jinja
    - user: root
    - group: root
    - mode: 0644

  service.running:
    - name: openvswitch-switch
    - enable: True
    - restart: True
    - watch:
      - pkg: manage-openvswitch
      - file: manage-openvswitch

{%- if dpdk %}
  cmd.run:
    - name: ovs-vsctl --no-wait set Open_vSwitch . other_config:dpdk-init=true
{%- endif %}

# Ensure the /var/log/openvswitch directory exists.
manage-openvswitch-override:
  file.managed:
    - name: /etc/systemd/system/openvswitch-switch.service.d/override.conf
    - source: salt://openvswitch/override.conf.jinja
    - template: jinja
    - user: root
    - group: root
    - mode: 0644
    - dir_mode: 0755
    - makedirs: True

manage-openvswitch-slice:
  file.managed:
    - name: /etc/systemd/system/openvswitch.slice
    - source: salt://openvswitch/openvswitch.slice.jinja
    - template: jinja
    - user: root
    - group: root
    - mode: 0644

reload-for-openvswitch-changes:
  module.run:
    - service.systemctl_reload:
    - onchanges:
      - file: manage-openvswitch-override
      - file: manage-openvswitch-slice

manage-openvswitch-start-dependency:
  file.replace:
    - name: /etc/init.d/openvswitch-switch
    - pattern: 'Required-Start:    \$network \$named \$remote_fs'
    - repl: 'Required-Start:    $network'
    - backup: False

manage-openvswitch-stop-dependency:
  file.line:
    - name: /etc/init.d/openvswitch-switch
    - content: 'Required-Stop:'
    - mode: delete
    - backup: False
