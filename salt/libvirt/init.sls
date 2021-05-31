manage-libvirt:
  pkg.latest:
    - pkgs:
      - ipxe-qemu
      - libvirt-daemon-system
      - python3-libvirt
      - qemu-system-x86
    - refresh: False

{% for rom in pillar.get('libvirt', {}).get('ipxe_roms', []) %}
manage-ipxe-roms:
  file.managed:
    - name: /usr/lib/ipxe/salt-openstack/{{ rom }}.rom
    - source: salt://libvirt/ipxe-roms/{{ rom }}.rom
    - user: root
    - group: root
    - mode: 0644
    - makedirs: True
{% endfor %}
