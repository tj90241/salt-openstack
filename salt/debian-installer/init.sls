install-netboot-kernel:
  file.managed:
    - name: /srv/tftp/debian-installer/amd64/linux
    - source: http://ftp.debian.org/debian/dists/{{ pillar['debian-installer']['release'] }}/main/installer-amd64/current/images/netboot/debian-installer/amd64/linux
    - source_hash: http://ftp.debian.org/debian/dists/{{ pillar['debian-installer']['release'] }}/main/installer-amd64/current/images/SHA256SUMS
    - source_hash_name: './netboot/debian-installer/amd64/linux'
    - keep_source: False
    - user: root
    - group: root
    - mode: 0644
    - dir_mode: 0755
    - makedirs: True

install-netboot-initrd:
  file.managed:
    - name: /srv/tftp/debian-installer/amd64/initrd.gz.orig
    - source: http://ftp.debian.org/debian/dists/{{ pillar['debian-installer']['release'] }}/main/installer-amd64/current/images/netboot/debian-installer/amd64/initrd.gz
    - source_hash: http://ftp.debian.org/debian/dists/{{ pillar['debian-installer']['release'] }}/main/installer-amd64/current/images/SHA256SUMS
    - source_hash_name: './netboot/debian-installer/amd64/initrd.gz'
    - keep_source: False
    - user: root
    - group: root
    - mode: 0644

install-netboot-packages:
  file.directory:
    - name: /srv/tftp/debian-installer/amd64/packages
    - user: root
    - group: root
    - mode: 0755
    - force: True
    - clean: True

  cmd.run:
    - name: "for file in `curl -s http://ftp.debian.org/debian/dists/{{ pillar['debian-installer']['release'] }}/main/debian-installer/binary-amd64/Packages.gz | zcat | sed -ne 's/^Filename: //p' | grep -E 'rdate-|libbsd0-|libmd0-'`; do curl -s \"http://ftp.debian.org/debian/${file}\" -o /srv/tftp/debian-installer/amd64/packages/`basename \"${file}\"`; done; find packages | cpio -oR root:root -H newc | gzip -9 > packages.gz"
    - cwd: /srv/tftp/debian-installer/amd64

install-netboot-firmware:
  file.managed:
    - name: /srv/tftp/debian-installer/firmware.cpio.gz
    - source: http://cdimage.debian.org/cdimage/unofficial/non-free/firmware/{{ pillar['debian-installer']['release'] }}/current/firmware.cpio.gz
    - source_hash: https://cdimage.debian.org/cdimage/unofficial/non-free/firmware/{{ pillar['debian-installer']['release'] }}/current/SHA512SUMS
    - source_hash_name: 'firmware.cpio.gz'
    - keep_source: False
    - user: root
    - group: root
    - mode: 0644

  cmd.run:
    - name: cat /srv/tftp/debian-installer/amd64/initrd.gz.orig /srv/tftp/debian-installer/firmware.cpio.gz /srv/tftp/debian-installer/amd64/packages.gz > /srv/tftp/debian-installer/amd64/initrd.gz
    - onchanges:
      - file: install-netboot-initrd
      - file: install-netboot-packages
      - file: install-netboot-firmware

install-netboot-splash-png:
  file.managed:
    - name: /srv/tftp/debian-installer/amd64/boot-screens/splash.png
    - source: http://ftp.debian.org/debian/dists/{{ pillar['debian-installer']['release'] }}/main/installer-amd64/current/images/netboot/debian-installer/amd64/boot-screens/splash.png
    - source_hash: http://ftp.debian.org/debian/dists/{{ pillar['debian-installer']['release'] }}/main/installer-amd64/current/images/SHA256SUMS
    - source_hash_name: './netboot/debian-installer/amd64/boot-screens/splash.png'
    - keep_source: False
    - user: root
    - group: root
    - mode: 0644
    - dir_mode: 0755
    - makedirs: True

install-netboot-stdmenu-cfg:
  file.managed:
    - name: /srv/tftp/debian-installer/amd64/boot-screens/.stdmenu.cfg
    - source: http://ftp.debian.org/debian/dists/{{ pillar['debian-installer']['release'] }}/main/installer-amd64/current/images/netboot/debian-installer/amd64/boot-screens/stdmenu.cfg
    - source_hash: http://ftp.debian.org/debian/dists/{{ pillar['debian-installer']['release'] }}/main/installer-amd64/current/images/SHA256SUMS
    - source_hash_name: './netboot/debian-installer/amd64/boot-screens/stdmenu.cfg'
    - keep_source: False
    - user: root
    - group: root
    - mode: 0644

copy-netboot-stdmenu-cfg:
  file.copy:
    - name: /srv/tftp/debian-installer/amd64/boot-screens/stdmenu.cfg
    - source: /srv/tftp/debian-installer/amd64/boot-screens/.stdmenu.cfg
    - force: True
    - user: root
    - group: root
    - mode: 0644
    - onchanges:
      - file: install-netboot-stdmenu-cfg

fixup-netboot-stdmenu-paths:
  file.replace:
    - name: /srv/tftp/debian-installer/amd64/boot-screens/stdmenu.cfg
    - pattern: ' debian-installer/'
    - repl: ' ::debian-installer/'
    - backup: False

manage-pxelinux-packages:
  pkg.installed:
    - pkgs:
      - pxelinux
      - syslinux-common
      - syslinux-efi
    - refresh: False
    - version: latest

  file.directory:
    - name: /srv/tftp/syslinux
    - user: root
    - group: root
    - mode: 0755

  {# file.recurse does not yet support local paths... #}
  {# https://www.github.com/saltstack/salt/issues/18563 #}
  cmd.run:
    - name: /bin/cp -r /usr/lib/syslinux/modules/* /srv/tftp/syslinux

{% for syslinux_type in ['bios', 'efi32', 'efi64'] %}
{% set image_paths = {
  'bios': '/usr/lib/PXELINUX/pxelinux.0',
  'efi32': '/usr/lib/SYSLINUX.EFI/efi32/syslinux.efi',
  'efi64': '/usr/lib/SYSLINUX.EFI/efi64/syslinux.efi',
} %}

manage-{{ syslinux_type }}-boot-image:
  file.managed:
    - name: /srv/tftp/syslinux/{{ syslinux_type }}/{{ salt['file.basename'](image_paths[syslinux_type]) }}
    - source: file:/{{ image_paths[syslinux_type] }}
    - user: root
    - group: root
    - mode: 0644

manage-{{ syslinux_type }}-pxelinux-cfg-directory:
  file.directory:
    - name: /srv/tftp/syslinux/{{ syslinux_type }}/pxelinux.cfg
    - user: root
    - group: root
    - mode: 0755
    - force: True

{% for mac, options in pillar.get('debian-installer', {}).get('macs', {}).items() %}
manage-{{ syslinux_type }}-{{ mac.replace(':', '-') }}-pxelinux-cfg:
  file.managed:
    - name: /srv/tftp/syslinux/{{ syslinux_type }}/pxelinux.cfg/01-{{ mac.lower().replace(':', '-') }}
    - source: salt://debian-installer/pxelinux.cfg.jinja
    - template: jinja
    - user: root
    - group: root
    - mode: 0644
    - context:
        domain: {{ options['domain'] }}
        hostname: {{ options['hostname'] }}
        preseed_url: {{ options['preseed_dir_url'] }}/{{ options['template'] }}.cfg
        cmdline: {{ pillar['debian-installer']['templates'][options['template']].get('cmdline', 'quiet') }}
        interface: {{ pillar['debian-installer']['templates'][options['template']]['interface'] }}
        syslinux_type: {{ syslinux_type }}
{% endfor %}

{% if salt['file.directory_exists']('/srv/tftp/syslinux/' + syslinux_type + '/pxelinux.cfg') %}
{% for file in salt['file.readdir']('/srv/tftp/syslinux/' + syslinux_type + '/pxelinux.cfg') %}
{% if (file not in ['.', '..'] and file | length < 4) or (file | length > 3 and file[3:].replace('-', ':').lower() not in pillar.get('debian-installer', {}).get('macs', {}).keys() | map('lower')) %}
manage-{{ syslinux_type }}-{{ file.replace(':', '-') }}-pxelinux-cfg:
  file.absent:
    - name: /srv/tftp/syslinux/{{ syslinux_type }}/pxelinux.cfg/{{ file }}
{% endif %}
{% endfor %}
{% endif %}
{% endfor %}

manage-preseed-template-directory:
  file.directory:
    - name: /srv/tftp/preseed
    - user: root
    - group: root
    - mode: 0755
    - force: True

{% for template, options in pillar.get('debian-installer', {}).get('templates', {}).items() %}
manage-{{ template }}-preseed-template:
  file.managed:
    - name: /srv/tftp/preseed/{{ template }}.cfg
    - source: salt://debian-installer/templates/{{ options['filename'] }}
    - template: jinja
    - user: root
    - group: root
    - mode: 0644
    - context:
        cmdline: {{ options['cmdline'] }}
        interface: {{ options['interface'] }}
{% endfor %}

{% for role in ['master', 'minion'] %}
manage-bootstrap-salt-{{ role }}-script:
  file.managed:
    - name: /srv/tftp/preseed/baseline-salt-{{ role }}
    - source: salt://debian-installer/baseline-salt-{{ role }}
    - user: root
    - group: root
    - mode: 0755
{% endfor %}

manage-virty-script:
  file.managed:
    - name: /srv/tftp/preseed/virty
    - source: salt://virty/virty
    - user: root
    - group: root
    - mode: 0755

{# If salt-openstack.tgz was dropped as part of deployment, delete it now. #}
{# It might contain secrets, and we're now feeding off the salt master. #}
manage-preseed-salt-openstack-repository:
  file.absent:
    - name: /srv/tftp/salt-openstack.tgz
