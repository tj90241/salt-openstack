include:
  - .logrotate
{% if 'salt-masters' in pillar.get('nodegroups', []) %}
  - .master
{% endif %}
  - .minion
