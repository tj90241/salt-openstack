manage-uuid-runtime:
  pkg.installed:
    - name: uuid-runtime
    - refresh: False
    - version: latest

  service.running:
    - name: uuidd.service
    - enable: True

{# Do not start the UUID daemon until time is synchronized. #}
  file.managed:
    - name: /etc/systemd/system/uuidd.service.d/override.conf
    - source: salt://uuid-runtime/override.conf
    - user: root
    - group: root
    - mode: 0644
    - dir_mode: 0755
    - makedirs: True

  module.run:
    - service.systemctl_reload:
    - onchanges:
      - file: manage-uuid-runtime
