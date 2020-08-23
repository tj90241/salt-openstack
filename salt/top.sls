base:
{# Essential daemons (time, entropy, etc.) #}
    - chrony

{# Host-specific default states #}
  'cpu_flags:pdpe1gb':
    - match: grain
    - hugepages1G

{# General states #}
  '*':
    - apt
    - curl
    - dosfstools
    - dnsutils
    - gnupg2
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
    - salt
    - sysstat
    - tmux
