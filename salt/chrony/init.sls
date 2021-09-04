manage-chrony:
  pkg.installed:
    - name: chrony
    - refresh: False
    - version: latest

  file.managed:
    - name: /etc/default/chrony
    - source: salt://chrony/default.jinja
    - template: jinja
    - user: root
    - group: root
    - mode: 0644
    - require:
      - pkg: manage-chrony

  service.running:
    - name: chrony
    - enable: True
    - restart: True
    - watch:
      - pkg: manage-chrony
      - file: manage-chrony
      - file: manage-chrony-configuration
      - file: manage-chrony-keys

{% if pillar.get('chrony', {}).get('driftfile', '/var/lib/chrony/chrony.drift') != '/var/lib/chrony/chrony.drift' %}
manage-chrony-driftfile:
  file.absent:
    - name: /var/lib/chrony/chrony.drift
    - require:
      - service: manage-chrony
{% endif %}

manage-chrony-configuration:
  file.recurse:
    - name: /etc/chrony
    - source: salt://chrony/chrony.jinja
    - template: jinja
    - user: root
    - group: root
    - dir_mode: 0755
    - file_mode: 0644
    - exclude_pat: chrony.keys

manage-chrony-keys:
  file.managed:
    - name: /etc/chrony/chrony.keys
    - source: salt://chrony/chrony.jinja/chrony.keys
    - template: jinja
    - user: root
    - group: root
    - mode: 0640

# Do not start chrony until the network/nameserver are up.
manage-chronyd-override:
  file.managed:
    - name: /etc/systemd/system/chrony.service.d/override.conf
    - source: salt://chrony/override.conf.jinja
    - template: jinja
    - user: root
    - group: root
    - mode: 0644
    - dir_mode: 0755
    - makedirs: True

  module.run:
    - service.systemctl_reload:
    - onchanges:
      - file: manage-chronyd-override

# chronyd is in play, so no need for ntp(d) or systemd-timesyncd.
manage-ntpd:
  pkg.purged:
    - name: ntp

  file.absent:
    - name: /etc/ntp.conf

manage-systemd-timesyncd:
  service.dead:
    - name: systemd-timesyncd
    - enable: False

# Provide time-sync.target functionality for chrony.
manage-chrony-wait:
  file.managed:
    - name: /etc/systemd/system/chrony-wait.service
    - source: salt://chrony/chrony-wait.service
    - user: root
    - group: root
    - mode: 0755

  module.run:
    - service.systemctl_reload:
    - onchanges:
      - file: manage-chrony-wait

  service.running:
    - name: chrony-wait
    - enable: True
    - restart: True
