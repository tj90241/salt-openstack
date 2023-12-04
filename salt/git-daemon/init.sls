manage-git-daemon:
  pkg.installed:
    - name: git-daemon-sysvinit
    - refresh: False
    - version: latest

  group.present:
    - name: git
    - system: True
    - addusers:
      - gitdaemon

  file.managed:
    - name: /etc/default/gitdaemon
    - source: salt://git-daemon/default
    - user: root
    - group: root
    - mode: 0644
    - require:
      - pkg: manage-git-daemon

  service.running:
    - name: git-daemon
    - enable: True
    - restart: True
    - watch:
      - pkg: manage-git-daemon
      - file: manage-git-daemon

manage-git-daemon-override:
  file.managed:
    - name: /etc/systemd/system/git-daemon.service.d/override.conf
    - source: salt://git-daemon/override.conf
    - user: root
    - group: root
    - mode: 0644
    - dir_mode: 0755
    - makedirs: True

  module.run:
    - service.systemctl_reload:
    - onchanges:
      - file: manage-git-daemon-override
