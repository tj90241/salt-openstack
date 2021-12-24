base:
{# Host-specific default states #}
  'cpu_flags:pse':
    - match: grain
    - hugepages2M

  'cpu_flags:pdpe1gb':
    - match: grain
    - hugepages1G

  'cpu_flags:rdt_a':
    - match: grain
    - resctrl

{# Critical/bootstrap role-specific states #}
  salt-masters:
    - match: nodegroup
    - certbot
    - ssl
    - openssl
    - nginx-light

  dhcp-servers:
    - match: nodegroup
    - isc-dhcp-server

  tftp-servers:
    - match: nodegroup
    - tftpd-hpa
    - debian-installer

  '*':
{# Essential configuration and daemons (DNS, time, entropy, SSL,  etc.) #}
    - gai
    - hosts
{% if salt['file.is_chrdev']('/dev/hwrng') and salt['file.directory_exists']('/sys/class/tpm') and salt['cmd.run']('/bin/ls -A /sys/class/tpm') | trim | length > 0 %}
    - rng-tools
{% elif 'rdrand' not in grains.get('cpu_flags', []) %}
    - haveged
{% else %}
    - rng-tools5
{% endif %}
    - openssl
    - ssl
{% if grains.get('virtual', 'virtual') == 'physical' %}
    - openvswitch
{% endif %}
    - dnsmasq
    - ifupdown
    # Intentionally out of order, bring up network before these.
    - chrony
    - consul
    - uuid-runtime

{# General states #}
    - salt
{%- if 'apt-servers' not in pillar.get('nodegroups', []) %}
    - apt.server
{%- endif %}
    - apt
    - arping
    - bash-completion
    - bpfcc-tools
    - cloud-init
    - curl
    - dosfstools
    - dnsutils
    - ethtool
    - eject
    - exim4
    - file
    - gawk
    - gnupg2
    - grub
    - hover
    - htop
    - iftop
    # Intentionally out of order, for initramfs-tools.
    - lzma
    - initramfs-tools
    - iotop
    - iperf
    - ipset
    - jq
    - kexec-tools
    - less
    - linux
    - lsof
    - man-db
    - manpages
    - manpages-dev
    - mariadb-client
    - motd
    - netcat
    - net-tools
    - numactl
    - parted
    - patch
    - procps
    - psmisc
    - python2
    - screen
    - sosreport
    - strace
    - sudo
    - sysctl
    - sysstat
    - tasksel
    - tcpdump
    - tmux
    - traceroute
    - udev
    - unzip
    - vim
    - xz-utils
    - zip
    - apt.autoremove

{# Bare metal tools (sensory, monitoring, etc.) #}
  'virtual:physical':
    - match: grain
{% if salt['smbios.get']('processor-manufacturer') == 'GenuineIntel' %}
    - intel-microcode
{% endif %}
    - lm-sensors
{% if salt['file.directory_exists']('/sys/class/ipmi') and salt['file.readdir']('/sys/class/ipmi') | difference(['.', '..']) | length > 0 %}
    - ipmitool
{% endif %}
    - nvme-cli
    - pciutils
    - smartmontools
    - usbutils

{# Wireless tools... #}
{% if salt['file.directory_exists']('/sys/class/net') %}
{% for netdev in salt['file.readdir']('/sys/class/net') | difference(['.', '..']) %}
{% set wireless_check = salt['file.join'](netdev, 'wireless') %}
{% if salt['file.directory_exists'](salt['file.join']('/sys/class/net', wireless_check)) %}
    - hostapd
    - iw
{% endif %}
{% endfor %}
{% endif %}

{# Role-specific states #}
  apt-servers:
    - match: nodegroup
    - apache2-utils
    - docker
    - docker.registry
    - expect
    - jenkins.apt-node
    - nginx-light
    - reprepro.gpg
    - reprepro
    - apt.server

  databases:
    - match: nodegroup
    - mariadb-server

  devpi-clients:
    - match: nodegroup
    - devpi
    - devpi.client

  devpi-servers:
    - match: nodegroup
    - nginx-light
    - devpi
    - devpi.server
    - devpi.users_indexes

  hypervisors:
    - match: nodegroup
    - libvirt
    - virty

  jenkins-nodes:
    - match: nodegroup
    - default-jre
    - docker
    - git
    - jenkins.node

  jenkins-servers:
    - match: nodegroup
    - default-jre
    - git
    - jenkins.server

  jumphosts:
    - match: nodegroup
    - haproxy
    - ipmitool
