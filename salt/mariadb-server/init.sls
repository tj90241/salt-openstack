{# If we already have a grastate file, then we were formerly clustered. #}
{%- set galera_cluster_exists = salt['file.file_exists']('/var/lib/mysql/grastate.dat') %}
{%- set bootstrap_galera_cluster = False %}

{# If we have no grastate, leverage Consul to nominate someone to bootstrap. #}
{# TODO: When rebuilding a node, this logic can potentially become perilous? #}
{%- set session_key = 'service/mysql/cluster' %}
{%- set sessions = salt['consul.session_list'](node=grains['id']) %}
{%- set session_uuid = sessions | selectattr('Name', '==', session_key) | list %}

{%- if session_uuid | length == 0 %}
{%- set session_uuid = salt['consul.session_create'](session_key)['ID'] -%}
{%- else %}
{%- set session_uuid = session_uuid[0]['ID'] -%}
{%- endif %}

{%- if salt['consul.session_acquire'](session_uuid, session_key) %}
{%- set bootstrap_galera_cluster = True %}
{%- endif %}
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
