manage-rng-tools:
  pkg.installed:
    - name: rng-tools-debian
    - refresh: False
    - version: latest

  file.managed:
    - name: /etc/default/rng-tools-debian
    - source: salt://rng-tools/default
    - user: root
    - group: root
    - mode: 0644

  service.running:
    - name: rng-tools
    - enable: True
    - restart: True
    - watch:
      - pkg: rng-tools-debian
      - file: manage-rng-tools
