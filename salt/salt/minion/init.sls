manage-salt-minion:
  pkg.installed:
    - name: salt-minion
    - refresh: False
    - version: latest

  file.recurse:
    - name: /etc/salt/minion.d
    - source: salt://salt/minion/conf.d.jinja
    - template: jinja

    {# Salt creates files in the minion.d directory for its own use. These
      files are prefixed with an underscore. A common example of this is the
      _schedule.conf file. #}
    - exclude_pat: _*

  {# If the configuration changed substantially, bounce the minion process. #}
  cmd.run:
    - name: salt-call --local service.restart salt-minion --out-file /dev/null
    - bg: True
    - onchanges:
      - pkg: manage-salt-minion
      - file: manage-salt-minion

  service.running:
    - name: salt-minion
    - enable: True
    - require:
      - file: manage-salt-minion

{# Do not start the salt minion until time is synchronized and the (local?) master is up. #}
manage-salt-minion-override:
  file.managed:
    - name: /etc/systemd/system/salt-minion.service.d/override.conf
    - source: salt://salt/minion/override.conf.jinja
    - template: jinja
    - user: root
    - group: root
    - mode: 0644
    - dir_mode: 0755
    - makedirs: True

  module.run:
    - service.systemctl_reload:
    - onchanges:
      - file: manage-salt-minion-override

{# Schedule a periodic 'saltutil.sync_all'. #}
{% if 'minion_saltutil_sync_all' in pillar.salt.get('schedule', {}) %}
schedule-minion-saltutil-sync-all:
  schedule.present:
    - function: saltutil.sync_all
    - cron: {{ pillar.salt.schedule.minion_saltutil_sync_all }}
{% endif %}

{# Schedule a periodic 'state.highstate'. #}
{% if 'minion_state_highstate' in pillar.salt.get('schedule', {}) %}
schedule-minion-state-highstate:
  schedule.present:
    - function: state.highstate
    - cron: {{ pillar.salt.schedule.minion_state_highstate }}
{% endif %}

{# Schedule a periodic 'system.reboot'. #}
{% if 'minion_system_reboot' in pillar.salt.get('schedule', {}) %}
schedule-minion-reboot:
  schedule.present:
    - function: system.reboot
    - cron: {{ pillar.salt.schedule.minion_system_reboot }}
{% endif %}
