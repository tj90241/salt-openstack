manage-debmirror:
  pkg.latest:
    - pkgs:
      - debian-archive-keyring
      - debmirror
      - ed
    - refresh: False

  file.managed:
    - name: /etc/debmirror.conf
    - source: salt://debmirror/debmirror.conf.jinja
    - template: jinja
    - user: root
    - group: root
    - mode: 0644

  schedule.present:
    - function: state.sls
    - job_args:
      - debmirror.sync
    - cron: '0 * * * *'
    - splay: 1800

manage-mirror-server:
  file.managed:
    - name: /etc/nginx/sites.d/mirror.conf
    - source: salt://debmirror/sites/mirror.conf.jinja
    - template: jinja
    - user: root
    - group: root
    - mode: 0640

  service.running:
    - name: nginx
    - enable: True
    - restart: True
    - watch:
      - file: manage-mirror-server
      - file: manage-mirror-server-override

manage-mirror-server-override:
  file.managed:
    - name: /etc/systemd/system/nginx.service.d/override.conf
    - source: salt://debmirror/override.conf.jinja
    - template: jinja
    - user: root
    - group: root
    - mode: 0644
    - dir_mode: 0755
    - makedirs: True

  module.run:
    - service.systemctl_reload:
    - onchanges:
      - file: manage-mirror-server-override
