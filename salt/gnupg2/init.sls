manage-gnupg2:
  pkg.installed:
    - name: gnupg2
    - refresh: False
    - latest: True

    {# Need gnupg* to be able to import apt keys. #}
    {# Frontload it very early into highstate runs. #}
    - order: 0
