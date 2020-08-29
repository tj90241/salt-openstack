manage-initramfs-tools:
  pkg.installed:
    - name: initramfs-tools
    - refresh: False
    - version: latest

  file.managed:
    - name: /etc/initramfs-tools/conf.d/salt-openstack.conf
    - source: salt://initramfs-tools/initramfs.conf.jinja
    - template: jinja
    - user: root
    - group: root
    - mode: 0644

  cmd.run:
    - name: update-initramfs -uk all
    - onchanges:
      - file: manage-initramfs-tools
