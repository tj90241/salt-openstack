manage-fcgiwrap:
  pkg.installed:
    - name: fcgiwrap
    - refresh: False
    - version: latest

  service.running:
    - name: fcgiwrap.service
    - enable: True
    - restart: True
