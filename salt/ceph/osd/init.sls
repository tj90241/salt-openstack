manage-ceph-osd:
  pkg.installed:
    - name: ceph-osd
    - refresh: False
    - version: latest

manage-ceph-osd-service-override:
  file.managed:
    - name: /etc/systemd/system/ceph-osd@.service.d/override.conf
    - source: salt://ceph/overrides.jinja/ceph-osd@.service
    - template: jinja
    - user: root
    - group: root
    - dir_mode: 0755
    - mode: 0644
    - makedirs: True

  module.run:
    - service.systemctl_reload:
    - onchanges:
      - file: manage-ceph-osd-service-override
