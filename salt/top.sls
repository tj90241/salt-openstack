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
    - jq
    - man-db
    - motd
    - salt
