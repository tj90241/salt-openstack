manage-salt-api:
  pkg.installed:
    - name: salt-api
    - refresh: False
    - version: latest

  file.managed:
    - name: /etc/salt/master.d/api.conf
    - source: salt://salt/master/conf.d.jinja/api.conf
    - template: jinja
    - user: root
    - group: root
    - mode: 0644
    - watch_in:
      - service: manage-salt-api

  service.running:
    - name: salt-api
    - enable: True
    - restart: True

{# Do not start the salt API until time is synchronized. #}
manage-salt-api-override:
  file.managed:
    - name: /etc/systemd/system/salt-api.service.d/override.conf
    - source: salt://salt/master/api/override.conf
    - user: root
    - group: root
    - mode: 0644
    - dir_mode: 0755
    - makedirs: True

  module.run:
    - service.systemctl_reload:
    - onchanges:
      - file: manage-salt-api-override
