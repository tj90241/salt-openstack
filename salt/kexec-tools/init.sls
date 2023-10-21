manage-kexec-tools:
  pkg.installed:
    - name: kexec-tools
    - refresh: False
    - version: latest

  file.managed:
    - name: /etc/default/kexec
    - source: salt://kexec-tools/default
    - user: root
    - group: root
    - mode: 0644

  service.running:
    - name: kexec-load
    - enable: True
    - restart: True
    - watch:
      - file: manage-kexec-tools
