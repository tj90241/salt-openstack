manage-libvirtd:
  pkg.latest:
    - pkgs:
      - ipxe-qemu
      - libvirt-daemon-system
      - libvirt-daemon-driver-storage-rbd
      - python3-libvirt
      - qemu-system-x86
    - refresh: False

  file.managed:
    - name: /etc/default/libvirtd
    - source: salt://libvirt/default.jinja
    - template: jinja
    - user: root
    - group: root
    - mode: 0644
    - require:
      - pkg: manage-libvirtd

  service.running:
    - name: libvirtd
    - enable: True
    - restart: True
    - watch:
      - pkg: manage-libvirtd
      - file: manage-libvirtd
      - file: manage-libvirt-configuration
      - file: manage-qemu-configuration

manage-libvirt-configuration:
  file.recurse:
    - name: /etc/libvirt
    - source: salt://libvirt/libvirt.jinja
    - template: jinja
    - user: root
    - group: root
    - dir_mode: 0755
    - file_mode: 0644
    - exclude_pat: E@^(qemu(?!-.*\.conf))|(secrets)$

manage-qemu-configuration:
  file.managed:
    - name: /etc/libvirt/qemu.conf
    - source: salt://libvirt/libvirt.jinja/qemu.conf
    - template: jinja
    - user: root
    - group: root
    - mode: 0600

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

{# Do not start libvirtd until time is synchronized and OVS is up. #}
manage-libvirtd-override:
  file.managed:
    - name: /etc/systemd/system/libvirtd.service.d/override.conf
    - source: salt://libvirt/override.conf
    - user: root
    - group: root
    - mode: 0644
    - dir_mode: 0755
    - makedirs: True

  module.run:
    - service.systemctl_reload:
    - onchanges:
      - file: manage-libvirtd-override
