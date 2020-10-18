{% from 'salt/map.jinja' import os_map with context %}

manage-saltstack-repo:
  {% if os_map.install_transport_https %}
  pkg.installed:
    - name: apt-transport-https
    - refresh: False
    {# We can't put a require_in on pkg: salt-{master,minion} here. #}
    - order: 3
  {% endif %}

  pkgrepo.managed:
    - humanname: SaltStack Debian Repo
    - file: /etc/apt/sources.list.d/saltstack.list
    - name: {{ os_map.pkgrepo }}
    - key_url: {{ os_map.key_url }}
    - clean_file: True

    {# We can't put a require_in on pkg: salt-{master,minion} here. #}
    - order: 4

  module.run:
    - pkg.refresh_db:
    - failhard: True

    {# We can't put a require_in on pkg: salt-{master,minion} here. #}
    - order: 5
    - onchanges:
      - pkgrepo: manage-saltstack-repo
