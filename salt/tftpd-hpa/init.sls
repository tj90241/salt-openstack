manage-tftpd-hpa:
  pkg.installed:
    - name: tftpd-hpa
    - refresh: False
    - version: latest

  file.managed:
    - name: /etc/default/tftpd-hpa
    - source: salt://tftpd-hpa/default.jinja
    - template: jinja
    - user: root
    - group: root
    - mode: 0644

  service.running:
    - name: tftpd-hpa
    - enable: True
    - restart: True
    - watch:
      - pkg: tftpd-hpa
      - file: manage-tftpd-hpa

{# Do not start the TFTP server until time is synchronized. #}
manage-tftpd-hpa-override:
  file.managed:
    - name: /etc/systemd/system/tftpd-hpa.service.d/override.conf
    - source: salt://tftpd-hpa/override.conf
    - user: root
    - group: root
    - mode: 0644
    - dir_mode: 0755
    - makedirs: True

  module.run:
    - service.systemctl_reload:
    - onchanges:
      - file: manage-tftpd-hpa-override
