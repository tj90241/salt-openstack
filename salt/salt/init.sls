include:
  - .logrotate
  - .pkgrepo
  - .packages
{% if 'salt-masters' in pillar.get('nodegroups', []) %}
  - .master
{% endif %}
  - .minion
