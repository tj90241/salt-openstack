grub:
  ipv6_disable: 0
  timeout: 1

  cmdline_linux:
    - transparent_hugepage=madvise

  cmdline_linux_default:
{% if grains.get('virtual', 'physical') != 'physical' %}
    - biosdevname=0
    - net.ifnames=0
    - console=tty0
    - console=ttyS0,115200
    - earlyprintk=ttyS0,115200
    - consoleblank=0
{% endif %}
    - systemd.show_status=false
