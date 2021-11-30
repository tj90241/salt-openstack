{% if 'dns-forwarders' not in pillar.get('nodegroups', []) %}
manage-dns-root-data:
  pkg.installed:
    - name: dns-root-data
    - refresh: False
    - version: latest

manage-dnsmasq:
  pkg.installed:
    - name: dnsmasq
    - refresh: False
    - version: latest

  file.managed:
    - name: /etc/default/dnsmasq
    - source: salt://dnsmasq/default
    - user: root
    - group: root
    - mode: 0644

  service.running:
    - name: dnsmasq
    - enable: True
    - restart: True
    - watch:
      - pkg: dnsmasq
      - pkg: dns-root-data
      - file: manage-dnsmasq
      - file: manage-dnsmasq-configuration
      - file: manage-dnsmasq-consul-configuration

manage-dnsmasq-configuration:
  file.managed:
    - name: /etc/dnsmasq.conf
    - source: salt://dnsmasq/dnsmasq.conf.jinja
    - template: jinja
    - user: root
    - group: root
    - mode: 0644

manage-dnsmasq-consul-configuration:
  file.managed:
    - name: /etc/dnsmasq.d/consul.conf
    - source: salt://dnsmasq/consul.conf.jinja
    - template: jinja
    - user: root
    - group: root
    - mode: 0644
{% endif %}
