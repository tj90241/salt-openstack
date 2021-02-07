manage-smartmontools:
  pkg.installed:
    - name: smartmontools
    - refresh: False
    - version: latest

{% if salt['file.directory_exists']('/sys/class/scsi_disk') %}
  service.running:
    - name: smartd
    - enable: True
    - restart: True
{% else %}
  service.dead:
    - name: smartd
    - enable: False
{% endif %}
    - watch:
      - pkg: manage-smartmontools
