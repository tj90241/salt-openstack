manage-ceph-radosgw:
  pkg.installed:
    - name: radosgw
    - refresh: False
    - version: latest

manage-ceph-radosgw-service-override:
  file.managed:
    - name: /etc/systemd/system/ceph-radosgw@.service.d/override.conf
    - source: salt://ceph/overrides.jinja/ceph-radosgw@.service
    - template: jinja
    - user: root
    - group: root
    - dir_mode: 0755
    - mode: 0644
    - makedirs: True

  module.run:
    - service.systemctl_reload:
    - onchanges:
      - file: manage-ceph-radosgw-service-override
