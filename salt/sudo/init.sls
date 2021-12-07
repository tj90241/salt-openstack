manage-sudo:
  pkg.installed:
    - name: sudo
    - refresh: False
    - version: latest

  file.managed:
    - name: /etc/sudoers.d/10-salt-openstack
    - source: salt://sudo/10-salt-openstack
    - user: root
    - group: root
    - mode: 0640
