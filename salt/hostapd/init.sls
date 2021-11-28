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
