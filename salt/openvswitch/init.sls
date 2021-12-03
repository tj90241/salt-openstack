manage-openvswitch:
  pkg.installed:
    - name: openvswitch-switch
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
      - file: manage-openvswitch-named-dependency

# Ensure the /var/log/openvswitch directory exists.
manage-openvswitch-override:
  file.managed:
    - name: /etc/systemd/system/openvswitch-switch.service.d/override.conf
    - source: salt://openvswitch/override.conf
    - user: root
    - group: root
    - mode: 0644
    - dir_mode: 0755
    - makedirs: True

  module.run:
    - service.systemctl_reload:
    - onchanges:
      - file: manage-openvswitch-override

manage-openvswitch-named-dependency:
  file.replace:
    - name: /etc/init.d/openvswitch-switch
    - pattern: 'Required-Start:    $network $named'
    - repl: 'Required-Start:    $network'
    - backup: False
