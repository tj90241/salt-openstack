manage-nvme-cli:
  pkg.installed:
    - name: nvme-cli
    - refresh: False
    - version: latest

  service.dead:
    - name: nvme-autoconnect
    - enable: False
