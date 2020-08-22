include:
  - .logrotate
  - .pkgrepo
  - .packages
{% if 'salt-master' in grains.get('roles', []) %}
  - .master
{% endif %}
  - .minion
