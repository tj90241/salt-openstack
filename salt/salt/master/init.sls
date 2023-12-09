{%- import_yaml 'salt/defaults.yaml' as salt_defaults -%}

include:
  - .sync
  - .api

{% if salt_defaults.get('master', {}).get('tmpfs_job_cache', False) %}
manage-salt-master-job-cache:
  file.managed:
    - name: /etc/systemd/system/var-cache-salt-master-jobs.mount
    - source: salt://salt/master/var-cache-salt-master-jobs.mount
    - user: root
    - group: root
    - mode: 0644
    - require_in:
      - pkg: manage-salt-master

  module.run:
    - service.systemctl_reload:
    - onchanges:
      - file: manage-salt-master-job-cache

  cmd.run:
    - name: "mv -v /var/cache/salt/master/jobs /var/cache/salt/master/jobs.old; mkdir -pv /var/cache/salt/master/jobs; systemctl start var-cache-salt-master-jobs.mount; find /var/cache/salt/master/jobs.old -maxdepth 1 -mindepth 1 -exec mv -vt /var/cache/salt/master/jobs {} + ; rmdir -v /var/cache/salt/master/jobs.old"
    - unless:
      - grep 'tmpfs /var/cache/salt/master/jobs tmpfs' /proc/mounts

  service.enabled:
    - name: var-cache-salt-master-jobs.mount
{% endif %}

manage-salt-master:
  pkg.installed:
    - name: salt-master
    - refresh: False
    - version: latest

  file.recurse:
    - name: /etc/salt/master.d
    - source: salt://salt/master/conf.d.jinja
    - template: jinja
    - clean: True

    {# Salt creates files in the master.d directory for its own use. These
      files are prefixed with an underscore. A common example of this is the
      _schedule.conf file. #}
    - exclude_pat: _*

  service.running:
    - name: salt-master
    - enable: True
    - restart: False

    {# Service will be reloaded/restarted when the watch-ed state(s) change. #}
    {# NOTE: The state *must* be applied with salt-call --local state.apply. #}
    - watch: 
      - pkg: manage-salt-master
      - file: manage-salt-master

manage-salt-minion-special-configuration:
  file.managed:
    - name: /etc/salt/minion.d/master.conf
    - source: salt://salt/master/master.conf
    - user: root
    - group: root
    - mode: '0644'

{# Do not start the salt master until time is synchronized. #}
manage-salt-master-override:
  file.managed:
    - name: /etc/systemd/system/salt-master.service.d/override.conf
    - source: salt://salt/master/override.conf
    - user: root
    - group: root
    - mode: 0644
    - dir_mode: 0755
    - makedirs: True

  module.run:
    - service.systemctl_reload:
    - onchanges:
      - file: manage-salt-master-override

manage-file-tree-pillar:
  file.directory:
    - name: /etc/salt/file_tree_pillar/hosts
    - user: root
    - group: salt
    - dir_mode: 0750
    - makedirs: True
    - follow_symlinks: False
    - watch_in:
      - service: manage-salt-master

manage-file-tree-pillar-perms:
  file.directory:
    - name: /etc/salt/file_tree_pillar
    - user: root
    - group: salt
    - file_mode: 0640
    - dir_mode: 0750
    - follow_symlinks: False
    - recurse:
      - user
      - group
      - mode

remove-master-defaults-conf:
  file.absent:
    - name: /etc/salt/master.d/_defaults.conf
    - watch_in:
      - service: manage-salt-master

{# Schedule a periodic 'salt-call --local state.apply salt.master' #}
{% if 'master_state_apply_self' in pillar.salt.get('schedule', {}) %}
schedule-master-state-apply-self:
  schedule.present:
    - function: cmd.run
    - job_args:
      - 'salt-call --local state.apply salt.master'
    - cron: {{ pillar.salt.schedule.master_state_apply_self }}
{% endif %}
