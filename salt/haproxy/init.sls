manage-haproxy:
  pkg.installed:
    - name: haproxy
    - refresh: False
    - version: latest

  file.managed:
    - name: /etc/default/haproxy
    - source: salt://haproxy/default
    - user: root
    - group: root
    - mode: 0644

  service.running:
    - name: haproxy
    - enable: True
    - reload: True
    - watch:
      - pkg: haproxy
      - file: manage-haproxy
      - file: manage-haproxy-d
      - file: manage-haproxy-configuration
      - file: manage-haproxy-ssl-cert

manage-haproxy-d:
  file.directory:
    - name: /etc/haproxy/haproxy.d
    - user: root
    - group: haproxy
    - mode: 0755

manage-haproxy-configuration:
  file.managed:
    - name: /etc/haproxy/haproxy.cfg
    - source: salt://haproxy/haproxy.cfg.jinja
    - template: jinja
    - user: root
    - group: root
    - mode: 0644

manage-haproxy-ssl-cert:
  file.managed:
    - name: /etc/haproxy/{{ grains.host }}.pem
    - contents_pillar:
      - ssl:fullchain.pem
      - ssl:privkey.pem
    - contents_newline: False
    - user: root
    - group: haproxy
    - mode: 0640

{% if 'consul' in pillar.get('haproxy', {}).get('backends', {}).keys() | list %}
manage-haproxy-consul-backend:
  file.managed:
    - name: /etc/haproxy/haproxy.d/consul.cfg
    - source: salt://haproxy/backends/consul.cfg.jinja
    - template: jinja
    - user: root
    - group: haproxy
    - mode: 0644
    - watch_in:
      - service: manage-haproxy

manage-haproxy-consul-cafile:
  file.managed:
    - name: /etc/haproxy/{{ pillar['consul']['site']['domain'] }}-ca.pem
    - contents_pillar:
      - consul:cacert.pem
    - user: root
    - group: haproxy
    - mode: 0640
    - watch_in:
      - service: manage-haproxy

manage-haproxy-consul-cert:
  file.managed:
    - name: /etc/haproxy/{{ pillar['consul']['site']['domain'] }}-crt.pem
    - contents_pillar:
      - consul:cli-cert.pem
      - consul:cli-key.pem
    - contents_newline: False
    - user: root
    - group: haproxy
    - mode: 0640
    - watch_in:
      - service: manage-haproxy
{% endif %}

{% if 'jenkins' in pillar.get('haproxy', {}).get('backends', {}).keys() | list %}
manage-haproxy-jenkins-backend:
  file.managed:
    - name: /etc/haproxy/haproxy.d/jenkins.cfg
    - source: salt://haproxy/backends/jenkins.cfg.jinja
    - template: jinja
    - user: root
    - group: haproxy
    - mode: 0644
    - context:
        max_servers: {{ pillar['haproxy']['backends']['jenkins'].get('max-servers', 1) }}
    - watch_in:
      - service: manage-haproxy
{% endif %}

{# Do not start haproxy until time is synchronized, Consul/OVS is up. #}
manage-haproxy-override:
  file.managed:
    - name: /etc/systemd/system/haproxy.service.d/override.conf
    - source: salt://haproxy/override.conf
    - user: root
    - group: root
    - mode: 0644
    - dir_mode: 0755
    - makedirs: True

  module.run:
    - service.systemctl_reload:
    - onchanges:
      - file: manage-haproxy-override
