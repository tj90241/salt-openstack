manage-ifupdown:
  pkg.installed:
    - name: ifupdown
    - refresh: False
    - version: latest

{% if pillar['ifupdown']['managed'] %}
  file.managed:
    - name: /etc/network/interfaces
    - source: salt://ifupdown/interfaces.jinja
    - template: jinja
    - user: root
    - group: root
    - mode: 0644
{% endif %}
