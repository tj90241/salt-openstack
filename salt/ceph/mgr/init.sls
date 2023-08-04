manage-ceph-mgr:
  pkg.installed:
    - name: ceph-mgr
    - refresh: False
    - version: latest

manage-ceph-mgr-service-override:
  file.managed:
    - name: /etc/systemd/system/ceph-mgr@.service.d/override.conf
    - source: salt://ceph/overrides.jinja/ceph-mgr@.service
    - template: jinja
    - user: root
    - group: root
    - dir_mode: 0755
    - mode: 0644
    - makedirs: True

  module.run:
    - service.systemctl_reload:
    - onchanges:
      - file: manage-ceph-mgr-service-override
