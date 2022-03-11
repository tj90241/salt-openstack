manage-udev-io-scheduler:
  file.managed:
    - name: /etc/udev/rules.d/98-io-scheduler.rules
    - source: salt://udev/98-io-scheduler.rules.jinja
    - template: jinja
    - user: root
    - group: root
    - mode: 0644
    - context:
        io_scheduler: {{ pillar.get('optimization', {}).get('io_scheduler', 'mq-deadline' if grains.get('virtual', 'physical') == 'physical' else 'none') }}

manage-udev-pci-sriov-vfs:
  file.managed:
    - name: /etc/udev/rules.d/99-net-sriov-vfs.rules
    - source: salt://udev/99-net-sriov-vfs.rules.jinja
    - template: jinja
    - user: root
    - group: root
    - mode: 0644
    - context:
        sriov_map: {{ pillar.get('udev', {}).get('net_sriov', {}) }}

trigger-udev-rules:
  cmd.run:
    - name: 'udevadm control --reload-rules && udevadm trigger'
    - onchanges:
      - file: manage-udev-io-scheduler
      - file: manage-udev-pci-sriov-vfs
