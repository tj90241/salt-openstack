manage-ceph-common:
  pkg.installed:
    - name: ceph-common
    - refresh: False
    - version: latest

manage-ceph-conf:
  file.managed:
    - name: /etc/ceph/ceph.conf
    - source: salt://ceph/ceph.conf.jinja
    - template: jinja
    - user: root
    - group: root
    - mode: 0644

manage-ceph-slice:
  file.managed:
    - name: /etc/systemd/system/ceph.slice
    - source: salt://ceph/ceph.slice.jinja
    - template: jinja
    - user: root
    - group: root
    - mode: 0644

  module.run:
    - service.systemctl_reload:
    - onchanges:
      - file: manage-ceph-slice
