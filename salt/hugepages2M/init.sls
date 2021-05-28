manage-dev-hugepages2M-dir:
  file.directory:
    - name: /dev/hugepages2M
    - user: root
    - group: root
    - mode: 0755

manage-dev-hugepages2M-mount:
  file.managed:
    - name: /etc/systemd/system/dev-hugepages2M.mount
    - source: salt://hugepages2M/dev-hugepages2M.mount
    - user: root
    - group: root
    - mode: 0644

  module.run:
    - service.systemctl_reload:
    - onchanges:
      - file: manage-dev-hugepages2M-mount

{% if salt['file.directory_exists']('/sys/kernel/mm/hugepages/hugepages-2048kB') %}
  service.running:
    - name: dev-hugepages2M.mount
    - enable: True
{% endif %}
