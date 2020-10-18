base:
  'roles:salt-master':
    - match: grain
    - salt.default.master

  'roles:timeserver':
    - match: grain
    - chrony.timeserver

  '{{ grains.id }}':
    - ignore_missing: True
    - certbot.{{ grains.id }}
    - grub.{{ grains.id }}
    - hover.{{ grains.id }}
    - salt.{{ grains.id }}

  '*':
    - apt
    - certbot
    - chrony
    - grub
    - hover
    - initramfs-tools
