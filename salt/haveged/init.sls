manage-haveged:
  pkg.installed:
    - name: haveged
    - refresh: False
    - version: latest

  file.managed:
    - name: /etc/default/haveged
    - source: salt://haveged/default
    - user: root
    - group: root
    - mode: 0644

  service.running:
    - name: haveged
    - enable: True
    - restart: True
    - watch:
      - pkg: manage-haveged
      - file: manage-haveged
