manage-dev-hugepages1G-dir:
  file.directory:
    - name: /dev/hugepages1G
    - user: root
    - group: root
    - mode: 0755

manage-dev-hugepages1G-mount:
  file.managed:
    - name: /etc/systemd/system/dev-hugepages1G.mount
    - source: salt://hugepages1G/dev-hugepages1G.mount
    - user: root
    - group: root
    - mode: 0644

  module.run:
    - service.systemctl_reload:
    - onchanges:
      - file: manage-dev-hugepages1G-mount

{% if salt['file.directory_exists']('/sys/kernel/mm/hugepages/hugepages-1048576kB') %}
  service.running:
    - name: dev-hugepages1G.mount
    - enable: True
{% endif %}
