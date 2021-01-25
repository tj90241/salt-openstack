install-netboot-kernel:
  file.managed:
    - name: /srv/tftp/debian-installer/amd64/linux
    - source: http://ftp.debian.org/debian/dists/stable/main/installer-amd64/current/images/netboot/debian-installer/amd64/linux
    - skip_verify: True
    - keep_source: False
    - user: root
    - group: root
    - mode: 0644
    - dir_mode: 0755
    - makedirs: True

install-netboot-initrd:
  file.managed:
    - name: /srv/tftp/debian-installer/amd64/initrd.gz.orig
    - source: http://ftp.debian.org/debian/dists/stable/main/installer-amd64/current/images/netboot/debian-installer/amd64/initrd.gz
    - skip_verify: True
    - keep_source: False
    - user: root
    - group: root
    - mode: 0644

install-netboot-firmware:
  file.managed:
    - name: /srv/tftp/debian-installer/firmware.cpio.gz
    - source: http://cdimage.debian.org/cdimage/unofficial/non-free/firmware/stable/current/firmware.cpio.gz
    - skip_verify: True
    - keep_source: False
    - user: root
    - group: root
    - mode: 0644

  cmd.run:
    - name: cat /srv/tftp/debian-installer/amd64/initrd.gz.orig /srv/tftp/debian-installer/firmware.cpio.gz > /srv/tftp/debian-installer/amd64/initrd.gz
    - onchanges:
      - file: install-netboot-initrd
      - file: install-netboot-firmware

install-netboot-splash:
  file.managed:
    - name: /srv/tftp/debian-installer/amd64/boot-screens/splash.png
    - source: http://ftp.debian.org/debian/dists/stable/main/installer-amd64/current/images/netboot/debian-installer/amd64/boot-screens/splash.png
    - skip_verify: True
    - keep_source: False
    - user: root
    - group: root
    - mode: 0644
    - dir_mode: 0755
    - makedirs: True

install-netboot-stdmenu:
  file.managed:
    - name: /srv/tftp/debian-installer/amd64/boot-screens/stdmenu.cfg
    - source: http://ftp.debian.org/debian/dists/stable/main/installer-amd64/current/images/netboot/debian-installer/amd64/boot-screens/stdmenu.cfg
    - skip_verify: True
    - keep_source: False
    - user: root
    - group: root
    - mode: 0644
