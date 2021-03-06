base:
{# Host-specific default states #}
  'cpu_flags:pse':
    - match: grain
    - hugepages2M

  'cpu_flags:pdpe1gb':
    - match: grain
    - hugepages1G

{# Critical/bootstrap role-specific states #}
  'roles:salt-master':
    - match: grain
    - certbot
    - consul.ca
    - ssl
    - openssl
    - nginx-light
    - twine

  'roles:dhcp-server':
    - match: grain
    - isc-dhcp-server

  'roles:tftp-server':
    - match: grain
    - tftpd-hpa
    - debian-installer

  'roles:consul-server':
    - match: grain
    - hosts
    - ssl
    - openssl
    - nginx-light
    - consul

  '*':
{# Essential configuration and daemons (time, entropy, SSL, service mesh, etc.) #}
    - gai
    - hosts
    - chrony
    - openssl
{% if salt['file.is_chrdev']('/dev/hwrng') and salt['file.directory_exists']('/sys/class/tpm') and salt['cmd.run']('/bin/ls -A /sys/class/tpm') | trim | length > 0 %}
    - rng-tools
{% elif 'rdrand' not in grains.get('cpu_flags', []) %}
    - haveged
{% else %}
    - rng-tools5
{% endif %}
    - ssl
    - consul
    - uuid-runtime

{# General states #}
    - apt
    - arping
    - bash-completion
    - cloud-init
    - curl
    - dosfstools
    - dnsutils
    - ethtool
    - exim4
    - gnupg2
    - grub
    - hover
    - htop
    - iftop
    - ifupdown
    - initramfs-tools
    - iotop
    - jq
    - kexec-tools
    - less
    - lsof
    - man-db
    - manpages
    - manpages-dev
    - motd
    - net-tools
    - numactl
    - parted
    - procps
    - psmisc
    - python2
    - salt
    - screen
    - sosreport
    - sysctl
    - sysstat
    - tasksel
    - tcpdump
    - tmux
    - traceroute
    - unzip
    - vim
    - zip

{# Bare metal tools (sensory, monitoring, etc.) #}
  'virtual:physical':
    - match: grain
{% if salt['file.directory_exists']('/sys/class/ipmi') and salt['cmd.run']('/bin/ls -A /sys/class/ipmi') | trim | length > 0 %}
    - ipmitool
{% endif %}
    - lm-sensors
    - nvme-cli
    - smartmontools

{# Role-specific states #}
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

  'roles:jumphost':
    - ipmitool
