base:
  # role-specific data and defaults
  'roles:devpi-client':
    - match: grain
    - devpi
    - devpi.packages

  'roles:devpi-server':
    - match: grain
    - devpi
    - devpi.packages
    - devpi.server
    - devpi.root

  'roles:salt-master':
    - match: grain
    - salt.default.master

  'roles:timeserver':
    - match: grain
    - chrony.timeserver

  # minion-specific data and defaults
  '{{ grains.id }}':
    - ignore_missing: True
    - certbot.{{ grains.id }}
    - devpi.hosts.{{ grains.id }}
    - grub.hosts.{{ grains.id }}
    - hover.{{ grains.id }}
    - salt.hosts.{{ grains.id }}

  # common data
  '*':
    - apt
    - certbot
    - chrony
    - grub
    - hover
    - initramfs-tools
    - openssl
    - salt
