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
    - patch
    - nginx-light
    - twine

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
    - apt.autoremove

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
