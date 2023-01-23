{# If we already have a grastate file, then we were formerly clustered. #}
{%- set galera_cluster_exists = salt['file.file_exists']('/var/lib/mysql/grastate.dat') %}

{# In the case where we have no grastate, leverage Consul to determine who is bootstrapping. #}
{%- set session_key = 'service/mysql/cluster' %}
{%- set sessions = salt['consul.session_list'](node=grains['id']) %}
{%- set session_uuid = sessions | selectattr('Name', '==', session_key) | list %}
{%- set session_uuid = salt['consul.session_create'](session_key)['ID']
                       if session_uuid | length == 0
                       else session_uuid[0]['ID'] -%}

{%- set bootstrap_galera_cluster = salt['consul.session_acquire'](session_uuid, session_key) -%}
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
    - context:
        configure_galera_cluster: {{ galera_cluster_exists or (not bootstrap_galera_cluster) }}

manage-my-cnf-alternatives-symlink:
  file.symlink:
    - name: /etc/mysql/my.cnf
    - target: /etc/alternatives/my.cnf
    - follow_symlinks: False
    - user: root
    - group: root

{# Do not start mariadb until time is synchronized, OVS is up. #}
manage-mariadb-server-override:
  file.managed:
    - name: /etc/systemd/system/mariadb.service.d/override.conf
    - source: salt://mariadb-server/override.conf
    - user: root
    - group: root
    - mode: 0644
    - dir_mode: 0755
    - makedirs: True

  module.run:
    - service.systemctl_reload:
    - onchanges:
      - file: manage-mariadb-server-override

{# Configure the service which provides Galera monitoring and Consul updates. #}
manage-galera-monitor:
  pkg.installed:
    - name: python3-pymysql
    - refresh: False
    - version: latest

  file.managed:
    - name: /usr/local/sbin/galera_monitor.py
    - source: salt://mariadb-server/galera_monitor.py.jinja
    - template: jinja
    - user: root
    - group: root
    - mode: 0755

manage-galera-monitor-service:
  file.managed:
    - name: /etc/systemd/system/galera-monitor.service
    - source: salt://mariadb-server/galera-monitor.service
    - user: root
    - group: root
    - mode: 0644

  module.run:
    - service.systemctl_reload:
    - onchanges:
      - file: manage-galera-monitor-service

  service.running:
    - name: galera-monitor
    - enable: True
    - restart: True
    - onchanges:
      - file: manage-galera-monitor-service
