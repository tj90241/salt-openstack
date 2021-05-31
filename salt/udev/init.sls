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

  cmd.run:
    - name: 'udevadm control --reload-rules && udevadm trigger'
    - onchanges:
      - file: manage-udev-pci-sriov-vfs
