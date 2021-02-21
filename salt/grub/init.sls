{%- set grub = pillar.get('grub', {}) -%}
{%- set cmdline_linux_default = grub.get('cmdline_linux_default', ['quiet']) + ([] if grub.get('ipv6_disable', False) in [False, 0] else ['ipv6.disable=1']) -%}

manage-grub-acpi-script:
  file.managed:
    - name: /etc/grub.d/01_custom_acpi
    - source: salt://grub/01_custom_acpi
    - user: root
    - group: root
    - chmod: 0755

manage-grub-timeout:
  file.line:
    - name: /etc/default/grub
    - content: GRUB_TIMEOUT={{ grub.get('timeout', 5) }}
    - match: ^GRUB_TIMEOUT=
    - mode: replace

manage-grub-cmdline-linux-default:
  file.line:
    - name: /etc/default/grub
    - content: GRUB_CMDLINE_LINUX_DEFAULT="{{ ' '.join(cmdline_linux_default) }}"
    - match: ^GRUB_CMDLINE_LINUX_DEFAULT=
    - mode: replace

manage-grub-cmdline-linux:
  file.line:
    - name: /etc/default/grub
    - content: GRUB_CMDLINE_LINUX="{{ ' '.join(grub.get('cmdline_linux', [''])) }}"
    - match: ^GRUB_CMDLINE_LINUX=
    - mode: replace

manage-grub:
  cmd.run:
    - name: /usr/sbin/update-grub
    - env:
        PATH: /usr/sbin:/usr/bin:/sbin:/bin
    - onchanges:
      - file: manage-grub-acpi-script
      - file: manage-grub-timeout
      - file: manage-grub-cmdline-linux-default
      - file: manage-grub-cmdline-linux

manage-debian-installer-modprobe:
  file.absent:
    - name: /etc/modprobe.d/local.conf
