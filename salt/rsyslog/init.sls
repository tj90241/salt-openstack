manage-rsyslog:
  pkg.installed:
    - name: rsyslog
    - refresh: False
    - version: latest

  file.managed:
    - name: /etc/rsyslog.conf
    - source: salt://rsyslog/rsyslog.conf
    - user: root
    - group: root
    - mode: '0644'

manage-rsyslog-service:
  service.running:
    - name: rsyslog.service
    - enable: True
    - restart: True
    - watch:
      - pkg: manage-rsyslog
      - file: manage-rsyslog

{# Do not start the rsyslog daemon until time is synchronized. #}
  file.managed:
    - name: /etc/systemd/system/rsyslog.service.d/override.conf
    - source: salt://rsyslog/override.conf
    - user: root
    - group: root
    - mode: 0644
    - dir_mode: 0755
    - makedirs: True

  module.run:
    - service.systemctl_reload:
    - onchanges:
      - file: manage-rsyslog-service
