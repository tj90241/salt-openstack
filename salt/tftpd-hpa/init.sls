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
