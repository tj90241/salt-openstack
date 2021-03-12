manage-gai-conf:
  file.managed:
    - name: /etc/gai.conf
    - source: salt://gai/gai.conf.jinja
    - template: jinja
    - user: root
    - group: root
    - mode: 0644
