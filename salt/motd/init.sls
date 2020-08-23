manage-motd:
  file.managed:
    - name: /etc/motd
    - contents:
      - ''
    - contents_newline: False
    - user: root
    - group: root
    - mode: 0644
