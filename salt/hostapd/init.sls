manage-hostapd:
  pkg.installed:
    - name: hostapd
    - refresh: False
    - version: latest
