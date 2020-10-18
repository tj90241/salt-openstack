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
