manage-sysstat:
  pkg.installed:
    - name: sysstat
    - refresh: False
    - version: latest
