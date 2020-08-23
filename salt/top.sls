base:
{# Host-specific default states #}
  'cpu_flags:pdpe1gb':
    - match: grain
    - hugepages1G

  '*':
{# Essential daemons (time, entropy, etc.) #}
    - chrony
{% if salt['file.is_chrdev']('/dev/hwrng') %}
    - rng-tools
{% elif 'rdrand' not in grains.get('cpu_flags', []) %}
    - haveged
{% else %}
    - rng-tools5
{% endif %}
    - uuid-runtime

{# General states #}
    - apt
    - curl
    - dosfstools
    - dnsutils
    - gnupg2
    - grub
    - htop
    - iftop
    - iotop
    - jq
    - kexec-tools
    - less
    - lsof
    - man-db
    - motd
    - net-tools
    - parted
    - salt
    - sysstat
    - tmux
    - traceroute
    - vim
    - zip
