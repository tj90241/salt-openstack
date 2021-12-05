manage-mariadb-server:
  pkg.installed:
    - name: mariadb-server
    - refresh: False
    - version: latest

  file.managed:
    - name: /etc/mysql/mariadb.cnf
    - source: salt://mariadb-server/mariadb.cnf.jinja
    - template: jinja
    - user: root
    - group: root
    - mode: 0644

  service.running:
    - name: mariadb
    - enable: True
    - restart: True
    - watch:
      - pkg: manage-mariadb-server
      - file: manage-mariadb-server
      - file: manage-mariadb-server-configuration

manage-mariadb-server-configuration:
  file.recurse:
    - name: /etc/mysql/mariadb.conf.d
    - source: salt://mariadb-server/mariadb.conf.d.jinja
    - template: jinja
    - user: root
    - group: root
    - clean: False
    - dir_mode: 0755
    - file_mode: 0644

manage-my-cnf-alternatives-symlink:
  file.symlink:
    - name: /etc/mysql/my.cnf
    - target: /etc/alternatives/my.cnf
    - follow_symlinks: False
    - user: root
    - group: root
