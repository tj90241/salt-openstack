{% import_yaml 'salt/defaults.yaml' as salt_defaults %}
{% from 'salt/map.jinja' import os_map with context %}

manage-salt-python-croniter:
  pkg.installed:
    - name: {{ os_map.croniter }}
    - refresh: False

    {# We can't put a require_in on pkg: salt-{master,minion} here. #}
    - order: 6

manage-salt-python-psutil:
  pkg.installed:
    - name: {{ os_map.psutil }}
    - refresh: False

    {# We can't put a require_in on pkg: salt-{master,minion} here. #}
    - order: 7

{# Salt 3000.x+ features a vendorized tornado; only install a system tornado for old releases. #}
{% if salt_defaults.get('release', 'latest') != 'latest' and (salt_defaults.get('release', 'latest') | string).split('.')[0] | int < 3001 %}
manage-salt-python-tornado:
  pkg.installed:
    - name: {{ os_map.tornado }}
    - refresh: False

    {# We can't put a require_in on pkg: salt-{master,minion} here. #}
    - order: 8
{% endif %}
