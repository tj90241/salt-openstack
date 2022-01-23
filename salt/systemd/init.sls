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

reload-for-systemd-changes:
  module.run:
    - service.systemctl_reload: