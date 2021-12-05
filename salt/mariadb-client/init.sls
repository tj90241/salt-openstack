manage-mariadb-client:
  pkg.installed:
    - name: mariadb-client
    - refresh: False
    - version: latest

  file.managed:
    - name: /etc/mysql/mariadb.cnf
    - source: salt://mariadb-server/mariadb.cnf.jinja
    - template: jinja
    - user: root
    - group: root
    - mode: 0644

manage-mariadb-client-configuration:
  file.recurse:
    - name: /etc/mysql/mariadb.conf.d
    - source: salt://mariadb-client/mariadb.conf.d.jinja
    - template: jinja
    - user: root
    - group: root
    - clean: False
    - dir_mode: 0755
    - file_mode: 0644

{% if 'databases' not in pillar.get('nodegroups', []) %}
manage-mariadb-client-galera-configuration:
  file.absent:
    - name: /etc/mysql/mariadb.conf.d/60-galera.cnf
{% endif %}

manage-client-my-cnf-alternatives-symlink:
  file.symlink:
    - name: /etc/mysql/my.cnf
    - target: /etc/alternatives/my.cnf
    - follow_symlinks: False
    - user: root
    - group: root
