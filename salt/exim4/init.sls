manage-exim4:
  pkg.installed:
    - name: exim4
    - refresh: False
    - version: latest

  file.managed:
    - name: /etc/default/exim4
    - source: salt://exim4/default
    - user: root
    - group: root
    - mode: 0644
    - require:
      - pkg: manage-exim4

  service.running:
    - name: exim4
    - enable: True
    - reload: True
    - watch:
      - pkg: manage-exim4
      - file: manage-exim4
      - cmd: manage-update-exim4.conf

manage-update-exim4.conf:
  file.managed:
    - name: /etc/exim4/update-exim4.conf.conf
    - source: salt://exim4/exim4/update-exim4.conf.conf.jinja
    - template: jinja
    - user: root
    - group: root
    - mode: 0644

  cmd.run:
    - name: /usr/sbin/update-exim4.conf -v
    - onchanges:
      - file: manage-update-exim4.conf

# Do not start exim4 until the network/nameserver are up.
manage-exim4-override:
  file.managed:
    - name: /etc/systemd/system/exim4.service.d/override.conf
    - source: salt://exim4/override.conf
    - user: root
    - group: root
    - mode: 0644
    - dir_mode: 0755
    - makedirs: True

  module.run:
    - service.systemctl_reload:
    - onchanges:
      - file: manage-exim4-override
