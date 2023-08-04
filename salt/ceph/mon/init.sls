manage-ceph-mon:
  pkg.installed:
    - name: ceph-mon
    - refresh: False
    - version: latest

manage-ceph-mon-service-override:
  file.managed:
    - name: /etc/systemd/system/ceph-mon@.service.d/override.conf
    - source: salt://ceph/overrides.jinja/ceph-mon@.service
    - template: jinja
    - user: root
    - group: root
    - dir_mode: 0755
    - mode: 0644
    - makedirs: True

  module.run:
    - service.systemctl_reload:
    - onchanges:
      - file: manage-ceph-mon-service-override
