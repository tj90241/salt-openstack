manage-wireguard:
  pkg.installed:
    - name: wireguard-tools
    - refresh: False
    - version: latest

  file.managed:
    - name: /etc/wireguard/wireguard.conf
    - source: salt://wireguard/wireguard.conf.jinja
    - template: jinja
    - user: root
    - group: root
    - mode: 0640

manage-wireguard-module:
  file.managed:
    - name: /etc/modprobe.d/wireguard.conf
    - source: salt://wireguard/module.conf
    - user: root
    - group: root
    - mode: 0644
