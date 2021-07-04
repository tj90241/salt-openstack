{%- set salt_openstack_server = pillar.get('apt', {}).get('salt_openstack_server', None) -%}

{%- if salt_openstack_server is not in ['', None] %}
manage-salt-openstack-apt-server:
  pkgrepo.managed:
    - humanname: salt-openstack APT Repository
    - file: /etc/apt/sources.list.d/salt-openstack.list
    - name: deb http://{{ salt_openstack_server }}/salt-openstack {{ grains.oscodename }} main
    - key_url: http://{{ salt_openstack_server }}/Release.gpg
{%- endif %}
