manage-smartmontools:
  pkg.installed:
    - name: smartmontools
    - refresh: False
    - version: latest

  service.running:
    - name: smartd
    - enable: True
    - restart: True
    - watch:
      - pkg: manage-smartmontools
