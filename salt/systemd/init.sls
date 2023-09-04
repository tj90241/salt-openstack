{% for slice in ['user', 'system'] %}
manage-{{ slice }}-slice:
  file.managed:
    - name: /etc/systemd/system/{{ slice }}.slice.d/override.conf
    - source: salt://systemd/overrides.jinja/{{ slice }}.slice
    - template: jinja
    - user: root
    - group: root
    - dir_mode: 0755
    - mode: 0644
    - makedirs: True
    - onchanges_in:
      - module: reload-for-systemd-changes
{% endfor %}

manage-low-latency-slice:
  file.managed:
    - name: /etc/systemd/system/low-latency.slice
    - source: salt://systemd/overrides.jinja/low-latency.slice
    - template: jinja
    - user: root
    - group: root
    - mode: 0644
    - onchanges_in:
      - module: reload-for-systemd-changes

reload-for-systemd-changes:
  module.run:
    - service.systemctl_reload:

manage-watchdog:
  file.managed:
    - name: /etc/systemd/system.conf.d/watchdog.conf
    - source: salt://systemd/watchdog.conf.jinja
    - template: jinja
    - user: root
    - group: root
    - mode: 0644
    - dir_mode: 0755
    - makedirs: True

  module.run:
    - service.systemctl_reload:
    - onchanges:
      - file: manage-watchdog
