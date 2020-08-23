base:
  'roles:salt-master':
    - match: grain
    - salt.default.master

  'roles:timeserver':
    - match: grain
    - chrony.timeserver

  '{{ grains.id }}':
    - ignore_missing: True
    - salt.{{ grains.id }}

  '*':
    - apt
    - chrony
