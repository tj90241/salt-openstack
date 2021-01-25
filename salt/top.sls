base:
{# Host-specific default states #}
  'cpu_flags:pse':
    - match: grain
    - hugepages2M

  'cpu_flags:pdpe1gb':
    - match: grain
    - hugepages1G

  'roles:salt-master':
    - match: grain
    - certbot
    - ssl
    - nginx-light

  '*':
{# Essential daemons (time, entropy, SSL, etc.) #}
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
    - uuid-runtime

{# Bare metal tools (sensory, monitoring, etc.) #}
  'virtual:physical':
    - match: grain
    - lm-sensors
    - nvme-cli
    - smartmontools

{# General states #}
    - apt
    - cloud-init
    - curl
    - dosfstools
    - dnsutils
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
    - tmux
    - traceroute
    - twine
    - unzip
    - vim
    - zip

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

  'roles:dhcp-server':
    - match: grain
    - isc-dhcp-server

  'roles:tftp-server':
    - match: grain
    - tftpd-hpa
    - debian-installer
