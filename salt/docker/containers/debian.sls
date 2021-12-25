{% set debian_version = salt['file.read']('/etc/debian_version').rstrip() %}

manage-docker-registry-login:
  cmd.run:
    - name: /usr/bin/docker login -u salt --password-stdin 'https://{{ grains.fqdn }}:443'
    - stdin: {{ pillar['docker']['registry']['users']['salt']['password'] }}

manage-debian-container-image:
  file.managed:
    - name: /usr/local/sbin/mkimage-debian.sh
    - source: salt://docker/containers/mkimage-debian.sh
    - user: root
    - group: root
    - mode: 0755

  cmd.run:
    - name: docker image pull '{{ grains.fqdn }}:443/debian:{{ debian_version }}' || /usr/local/sbin/mkimage-debian.sh

manage-docker-registry-logout:
  cmd.run:
    - name: /usr/bin/docker logout 'https://{{ grains.fqdn }}:443'
