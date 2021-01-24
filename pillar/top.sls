base:
  # common data
  '*':
    - apt
    - certbot
    - chrony
    - grub
    - hover
    - initramfs-tools
    - openssl
    - nginx
    - salt
    - sysctl

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
    - openstack.devpi.indexes
    - openstack.devpi.user

  'roles:salt-master':
    - match: grain
    - salt.default.master

  'roles:timeserver':
    - match: grain
    - chrony.timeserver

  # minion-specific data and defaults
  '{{ grains.id }}':
    - ignore_missing: True
    - certbot.hosts.{{ grains.id }}
    - chrony.hosts.{{ grains.id }}
    - devpi.hosts.{{ grains.id }}
    - grub.hosts.{{ grains.id }}
    - hover.hosts.{{ grains.id }}
    - nginx.hosts.{{ grains.id }}
    - salt.hosts.{{ grains.id }}
    - sysctl.hosts.{{ grains.id }}
