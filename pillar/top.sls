base:
  'roles:salt-master':
    - match: grain
    - salt.default.master

  '{{ grains.id }}':
    - ignore_missing: True
    - salt.{{ grains.id }}

  '*':
    - apt
