manage-htop:
  pkg.installed:
    - name: htop
    - refresh: False
    - version: latest

  file.managed:
    - name: /etc/htoprc
    - source: salt://htop/htoprc.jinja
    - template: jinja
    - user: root
    - group: root
    - mode: 0644
