base:
{# Host-specific default states #}
  'cpu_flags:pdpe1gb':
    - match: grain
    - hugepages1G

{# General states #}
  '*':
    - apt
    - htop
    - man-db
    - salt
