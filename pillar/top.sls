base:
  'roles:salt-master':
    - match: grain
    - salt.default.master

  'roles:timeserver':
    - match: grain
    - chrony.timeserver

  '{{ grains.id }}':
    - ignore_missing: True
    - grub.{{ grains.id }}
    - salt.{{ grains.id }}

  '*':
    - apt
    - chrony
    - grub
    - initramfs-tools
