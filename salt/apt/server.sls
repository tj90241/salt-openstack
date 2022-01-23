{% if pillar.get('apt', {}).get('use-salt-openstack-repo', False) %}
{% for repository in pillar.get('reprepro', {}).get('repositories', []) %}
manage-{{ repository }}-apt-server:
  pkgrepo.managed:
    - humanname: {{ repository }} APT Repository
    - file: /etc/apt/sources.list.d/{{ repository }}.list
    - name: deb http://apt.service.{{ pillar['consul']['site']['domain'] }}:8080/{{ repository }} {{ grains.oscodename }} main
    - key_url: http://apt.service.{{ pillar['consul']['site']['domain'] }}:8080/Release.gpg
{% endfor %}
{% endif %}
