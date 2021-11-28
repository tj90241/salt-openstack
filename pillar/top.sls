base:
  # common data
  '*':
    - apt
    - certbot
    - chrony
    - consul
    - consul.key
    - consul.site
    - grub
    - hosts
    - hover
    - ifupdown
    - initramfs-tools
    - openssl
    - nginx
    - salt
    - sysctl

  # role-specific data and defaults
  'roles:apt-server':
    - match: grain
    - apt.gpg
    - jenkins
    - jenkins.credentials.apt-node

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

  'roles:dhcp-server':
    - match: grain
    - isc-dhcp-server

  'roles:jenkins-node':
    - match: grain
    - jenkins
    - jenkins.credentials.node

  'roles:jenkins-server':
    - match: grain
    - jenkins
    - jenkins.controller
    - jenkins.credentials.controller
    - jenkins.credentials.node

  'salt-masters':
    - ignore_missing: True
    - match: nodegroup
    - consul.bootstrap
    - salt.default.master

  'roles:tftp-server':
    - match: grain
    - debian-installer
    - tftpd-hpa

  'roles:timeserver':
    - match: grain
    - chrony.timeserver

  # minion-specific data and defaults
  '{{ grains.id }}':
    - ignore_missing: True
    - apt.server
    - certbot.hosts.{{ grains.id }}
    - chrony.hosts.{{ grains.id }}
    - debian-installer.hosts.{{ grains.id }}
    - devpi.hosts.{{ grains.id }}
    - grub.hosts.{{ grains.id }}
    - haproxy.hosts.{{ grains.id }}
    - hostapd.hosts.{{ grains.id }}
    - hover.hosts.{{ grains.id }}
    - ifupdown.hosts.{{ grains.id }}
    - isc-dhcp-server.hosts.{{ grains.id }}
    - libvirt.hosts.{{ grains.id }}
    - nginx.hosts.{{ grains.id }}
    - salt.hosts.{{ grains.id }}
    - sysctl.hosts.{{ grains.id }}
    - tftpd-hpa.hosts.{{ grains.id }}
    - udev.hosts.{{ grains.id }}
    - virty.hosts.{{ grains.id }}
