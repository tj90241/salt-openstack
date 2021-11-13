base:
{# Host-specific default states #}
  'cpu_flags:pse':
    - match: grain
    - hugepages2M

  'cpu_flags:pdpe1gb':
    - match: grain
    - hugepages1G

{# Critical/bootstrap role-specific states #}
  salt-masters:
    - match: nodegroup
    - certbot
    - consul.ca
    - ssl
    - openssl
    - nginx-light

  'roles:dhcp-server':
    - match: grain
    - isc-dhcp-server

  'roles:tftp-server':
    - match: grain
    - tftpd-hpa
    - debian-installer

  '*':
{# Essential configuration and daemons (DNS, time, entropy, SSL,  etc.) #}
    - gai
    - hosts
    - chrony
{% if salt['file.is_chrdev']('/dev/hwrng') and salt['file.directory_exists']('/sys/class/tpm') and salt['cmd.run']('/bin/ls -A /sys/class/tpm') | trim | length > 0 %}
    - rng-tools
{% elif 'rdrand' not in grains.get('cpu_flags', []) %}
    - haveged
{% else %}
    - rng-tools5
{% endif %}
    - openssl
    - ssl
    - consul
    - dnsmasq
    - ifupdown
    - uuid-runtime

{# General states #}
    - salt
{%- if 'apt-server' not in grains.get('roles', []) %}
    - apt.server
{%- endif %}
    - apt
    - arping
    - bash-completion
    - cloud-init
    - curl
    - dosfstools
    - dnsutils
    - ethtool
    - eject
    - exim4
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
    - lsof
    - man-db
    - manpages
    - manpages-dev
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
{% if salt['file.directory_exists']('/sys/class/ipmi') and salt['file.readdir']('/sys/class/ipmi') | difference(['.', '..']) | length > 0 %}
    - ipmitool
{% endif %}
    - lm-sensors
    - nvme-cli
    - pciutils
    - smartmontools
    - usbutils
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
  'roles:apt-server':
    - match: grain
    - expect
    - jenkins.apt-node
    - nginx-light
    - reprepro.gpg
    - reprepro
    - apt.server

  'roles:devpi-client':
    - match: grain
    - devpi
    - devpi.client

  'roles:devpi-server':
    - match: grain
    - nginx-light
    - devpi
    - devpi.server
    - devpi.users_indexes

  'roles:hypervisor':
    - match: grain
    - libvirt
    - virty

  'roles:jenkins-node':
    - match: grain
    - default-jre
    - git
    - jenkins.node

  'roles:jenkins-server':
    - match: grain
    - default-jre
    - git
    - jenkins.server

  'roles:jumphost':
    - match: grain
    - haproxy
    - ipmitool
