manage-apache2-utils:
  pkg.installed:
    - name: apache2-utils
    - refresh: False
    - version: latest
