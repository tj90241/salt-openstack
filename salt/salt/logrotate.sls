manage-salt-logrotate-conf:
  file.managed:
    - name: /etc/logrotate.d/salt-common
    - source: salt://salt/logrotate.conf.jinja
    - template: jinja
    - user: root
    - group: root
    - mode: 0644
    - onlyif:
      - test -d /etc/logrotate.d
