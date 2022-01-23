base:
  # common data
  '*':
    - apt
    - certbot
    - chrony
    - consul
    - consul.key
    - consul.site
    - cpufrequtils
    - grub
    - hosts
    - hover
    - ifupdown
    - initramfs-tools
    - openssl
    - nginx
    - reprepro
    - salt
    - sysctl

  # role-specific data and defaults
  apt-servers:
    - match: nodegroup
    - apt.gpg
    - docker.registry
    - jenkins
    - jenkins.credentials.apt-node
    - jenkins.credentials.docker

  consul-servers:
    - match: nodegroup
    - roles

  databases:
    - match: nodegroup
    - mariadb.galera
    - mariadb.server

  devpi-clients:
    - match: nodegroup
    - devpi
    - devpi.packages

  devpi-servers:
    - match: nodegroup
    - devpi
    - devpi.packages
    - devpi.server
    - devpi.root
    - openstack.devpi.indexes
    - openstack.devpi.user

  dhcp-servers:
    - match: nodegroup
    - isc-dhcp-server

  jenkins-nodes:
    - match: nodegroup
    - jenkins
    - jenkins.credentials.docker
    - jenkins.credentials.node

  jenkins-servers:
    - match: nodegroup
    - jenkins
    - jenkins.controller
    - jenkins.credentials.controller
    - jenkins.credentials.node
    - jenkins.credentials.users
    - jenkins.credentials.salt

  'salt-masters':
    - ignore_missing: True
    - match: nodegroup
    - consul.bootstrap
    - jenkins
    - jenkins.credentials.salt
    - salt.default.master
    - roles

  tftp-servers:
    - match: nodegroup
    - debian-installer
    - tftpd-hpa

  timeservers:
    - match: nodegroup
    - chrony.timeserver

  # minion-specific data and defaults
  '{{ grains.id }}':
    - ignore_missing: True
    - apt.hosts.{{ grains.id }}
    - certbot.hosts.{{ grains.id }}
    - chrony.hosts.{{ grains.id }}
    - cpufrequtils.hosts.{{ grains.id }}
    - debian-installer.hosts.{{ grains.id }}
    - devpi.hosts.{{ grains.id }}
    - grub.hosts.{{ grains.id }}
    - haproxy.hosts.{{ grains.id }}
    - hostapd.hosts.{{ grains.id }}
    - hover.hosts.{{ grains.id }}
    - ifupdown.hosts.{{ grains.id }}
    - isc-dhcp-server.hosts.{{ grains.id }}
    - libvirt.hosts.{{ grains.id }}
    - optimization.hosts.{{ grains.id }}
    - nginx.hosts.{{ grains.id }}
    - reprepro.hosts.{{ grains.id }}
    - salt.hosts.{{ grains.id }}
    - sysctl.hosts.{{ grains.id }}
    - tftpd-hpa.hosts.{{ grains.id }}
    - udev.hosts.{{ grains.id }}
    - virty.hosts.{{ grains.id }}
