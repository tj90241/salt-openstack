manage-netcat:
  pkg.installed:
    - name: netcat-openbsd
    - refresh: False
    - version: latest
