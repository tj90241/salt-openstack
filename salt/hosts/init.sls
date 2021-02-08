manage-etc-hosts:
  file.managed:
    - name: /etc/hosts
    - source: salt://hosts/hosts.jinja
    - template: jinja
    - user: root
    - group: root
    - mode: 0644
