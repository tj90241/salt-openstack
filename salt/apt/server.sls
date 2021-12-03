{# TODO: Replace/default to a Consul service... #}
{%- set salt_openstack_server = pillar.get('apt', {}).get('salt_openstack_server', 'apt' + '.node.' + pillar['consul']['site']['domain'] + ':8080') -%}

{% if pillar.get('apt', {}).get('use-salt-openstack-repo', False) %}
manage-salt-openstack-apt-server:
  pkgrepo.managed:
    - humanname: salt-openstack APT Repository
    - file: /etc/apt/sources.list.d/salt-openstack.list
    - name: deb http://{{ salt_openstack_server }}/salt-openstack {{ grains.oscodename }} main
    - key_url: http://{{ salt_openstack_server }}/Release.gpg
{% endif %}
