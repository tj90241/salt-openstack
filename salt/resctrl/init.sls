manage-resctrl-mount:
  file.managed:
    - name: /etc/systemd/system/sys-fs-resctrl.mount
    - source: salt://resctrl/sys-fs-resctrl.mount
    - user: root
    - group: root
    - mode: 0644

  module.run:
    - service.systemctl_reload:
    - onchanges:
      - file: manage-resctrl-mount

  service.running:
    - name: sys-fs-resctrl.mount
    - enable: True
