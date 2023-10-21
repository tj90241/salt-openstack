manage-kdump-tools:
  pkg.installed:
    - name: kdump-tools
    - refresh: False
    - version: latest

  file.managed:
    - name: /etc/default/kdump-tools
    - source: salt://kdump-tools/default.jinja
    - template: jinja
    - user: root
    - group: root
    - mode: 0644

manage-kdump-tools-grub:
  file.managed:
    - name: /etc/default/grub.d/kdump-tools.cfg
    - source: salt://kdump-tools/kdump-tools.cfg.jinja
    - template: jinja
    - user: root
    - group: root
    - mode: 0644

  cmd.run:
    - name: /usr/sbin/update-grub
    - env:
        PATH: /usr/sbin:/usr/bin:/sbin:/bin
    - onchanges:
      - file: manage-kdump-tools-grub

{# SysVInit script clashes with systemd in weird ways... #}
manage-kdump-tools-service:
  file.absent:
    - name: /lib/systemd/system/kdump-tools.service

  module.run:
    - service.systemctl_reload:
    - onchanges:
      - file: manage-kdump-tools-service

  service.running:
    - name: kdump-tools
    - enable: True
    - restart: True
    - watch:
      - file: manage-kdump-tools
    - require:
      - module: manage-kdump-tools-service
      - file: manage-kdump-tools-service

manage-makedumpfile:
  pkg.installed:
    - name: makedumpfile
    - refresh: False
    - version: latest
