manage-cpufrequtils:
  pkg.installed:
    - name: cpufrequtils
    - refresh: False
    - version: latest

  file.managed:
    - name: /etc/default/cpufrequtils
    - source: salt://cpufrequtils/default.jinja
    - template: jinja
    - user: root
    - group: root
    - mode: 0644

  service.running:
    - name: cpufrequtils
    - enable: True
    - restart: True
    - watch:
      - pkg: manage-cpufrequtils
      - file: manage-cpufrequtils
