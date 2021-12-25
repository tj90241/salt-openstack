{% if pillar.get('apt', {}).get('use-salt-openstack-repo', False) %}
manage-salt-openstack-apt-server:
  pkgrepo.managed:
    - humanname: salt-openstack APT Repository
    - file: /etc/apt/sources.list.d/salt-openstack.list
    - name: deb http://apt.service.{{ pillar['consul']['site']['domain'] }}:8080/salt-openstack {{ grains.oscodename }} main
    - key_url: http://apt.service.{{ pillar['consul']['site']['domain'] }}:8080/Release.gpg
{% endif %}
