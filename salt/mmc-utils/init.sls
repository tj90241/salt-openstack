{% if salt['file.directory_exists']('/sys/class/mmc_host') and salt['file.readdir']('/sys/class/mmc_host') | difference(['.', '..']) | length > 0 %}
manage-mmc-utils:
  pkg.installed:
    - name: mmc-utils
    - refresh: False
    - version: latest
{% endif %}
