manage-ethtool:
  pkg.installed:
    - name: ethtool
    - refresh: False
    - version: latest
