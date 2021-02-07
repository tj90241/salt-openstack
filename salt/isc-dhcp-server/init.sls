manage-isc-dhcp-server:
  pkg.installed:
    - name: isc-dhcp-server
    - refresh: False
    - version: latest

  file.managed:
    - name: /etc/default/isc-dhcp-server
    - source: salt://isc-dhcp-server/default.jinja
    - template: jinja
    - user: root
    - group: root
    - mode: 0644

  service.running:
    - name: isc-dhcp-server
    - enable: True
    - restart: True
    - watch:
      - pkg: isc-dhcp-server
      - file: manage-isc-dhcp-server
      - file: manage-dhcpd-conf

manage-dhcpd-conf:
  file.managed:
    - name: /etc/dhcp/dhcpd.conf
    - source: salt://isc-dhcp-server/dhcpd.conf.jinja
    - template: jinja
    - user: root
    - group: root
    - mode: 0644
    - dir_mode: 0755
    - makedirs: True

{# Do not start the DHCP server until time is synchronized. #}
manage-isc-dhcp-server-override:
  file.managed:
    - name: /etc/systemd/system/isc-dhcp-server.service.d/override.conf
    - source: salt://isc-dhcp-server/override.conf
    - user: root
    - group: root
    - mode: 0644
    - dir_mode: 0755
    - makedirs: True

  module.run:
    - service.systemctl_reload:
    - onchanges:
      - file: manage-isc-dhcp-server-override
