manage-intel-microcode:
  pkg.installed:
    - name: intel-microcode
    - refresh: False
    - version: latest

  file.managed:
    - name: /etc/default/intel-microcode
    - source: salt://intel-microcode/default.jinja
    - template: jinja
    - user: root
    - group: root
    - mode: 0644

  cmd.run:
    - name: update-initramfs -uk all
    - onchanges:
      - file: manage-intel-microcode
