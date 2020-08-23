manage-rng-tools5:
  pkg.installed:
    - name: rng-tools5
    - refresh: False
    - version: latest

  service.running:
    - name: rngd
    - enable: True
    - require:
      - pkg: rng-tools5
