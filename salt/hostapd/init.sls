manage-hostapd:
  pkg.installed:
    - name: hostapd
    - refresh: False
    - version: latest

  file.managed:
    - name: /etc/default/hostapd
    - source: salt://hostapd/default.jinja
    - template: jinja
    - user: root
    - group: root
    - mode: 0644
    - require:
      - pkg: manage-hostapd

  service.running:
    - name: hostapd
    - enable: True
    - restart: True
    - watch:
      - pkg: manage-hostapd
      - file: manage-hostapd
      - file: manage-hostapd-configuration

manage-hostapd-configuration:
  file.managed:
    - name: /etc/hostapd/hostapd.conf
    - source: salt://hostapd/hostapd.conf.jinja
    - template: jinja
    - user: root
    - group: root
    - mode: 0644

{# Do not start hostapd until OVS is up. #}
manage-hostapd-override:
  file.managed:
    - name: /etc/systemd/system/hostapd.service.d/override.conf
    - source: salt://hostapd/override.conf
    - user: root
    - group: root
    - mode: 0644
    - dir_mode: 0755
    - makedirs: True

  module.run:
    - service.systemctl_reload:
    - onchanges:
      - file: manage-hostapd-override
