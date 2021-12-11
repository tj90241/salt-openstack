manage-man-db:
  pkg.installed:
    - name: man-db
    - refresh: False
    - version: latest

  file.managed:
    - name: /etc/manpath.config
    - source: salt://man-db/manpath.config
    - user: root
    - group: root
    - mode: 0644

  cmd.run:
    - name: /usr/bin/mandb
    - runas: man
    - onchanges:
      - file: manage-man-db
