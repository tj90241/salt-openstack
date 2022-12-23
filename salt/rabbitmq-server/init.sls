manage-rabbitmq-directory:
  file.directory:
    - name: /var/lib/rabbitmq
    - user: rabbitmq
    - group: rabbitmq
    - mode: 0755
    - require:
      - pkg: rabbitmq-server

manage-rabbitmq-log-directory:
  file.directory:
    - name: /var/log/rabbitmq
    - user: rabbitmq
    - group: rabbitmq
    - mode: 0750
    - require:
      - pkg: rabbitmq-server

manage-rabbitmq-mnesia-directory:
  file.directory:
    - name: /var/lib/rabbitmq/mnesia
    - user: rabbitmq
    - group: rabbitmq
    - mode: 0750
    - require:
      - pkg: rabbitmq-server

manage-rabbitmq-server:
  pkg.installed:
    - name: rabbitmq-server
    - refresh: False
    - latest: True

  service.running:
    - name: rabbitmq-server
    - enable: True
    - restart: True
    - require:
      - file: manage-rabbitmq-directory
      - file: manage-rabbitmq-log-directory
      - file: manage-rabbitmq-mnesia-directory
    - watch:
      - file: manage-rabbitmq-server
      - file: manage-rabbitmq-server-configuration
      - pkg: rabbitmq-server

  file.managed:
    - name: /etc/default/rabbitmq-server
    - source: salt://rabbitmq-server/default
    - user: root
    - group: root
    - require:
      - pkg: rabbitmq-server

manage-rabbitmq-server-configuration:
  file.recurse:
    - name: /etc/rabbitmq
    - source: salt://rabbitmq-server/rabbitmq.jinja
    - template: jinja
    - user: rabbitmq
    - group: rabbitmq
    - file_mode: 0644
    - dir_mode: 0755
    #- clean: True
    - require:
      - pkg: rabbitmq-server

{% for ssl in ['chain', 'cert', 'privkey'] %}
manage-rabbitmq-ssl-mgmt-{{ ssl }}:
  file.managed:
    - name: /etc/rabbitmq/ssl/mgmt_{{ ssl }}.pem
    - contents_pillar:
      - ssl:{{ ssl }}.pem
    - user: rabbitmq
    - group: rabbitmq
    - mode: 0640
    - dir_mode: 0750
    - makedirs: True
    - watch_in:
      - service: rabbitmq-server
{% endfor %}

manage-rabbitmq-consul-cacert:
  file.managed:
    - name: /etc/rabbitmq/ssl/consul_chain.pem
    - contents_pillar: 'consul:cacert.pem'
    - contents_newline: False
    - user: rabbitmq
    - group: rabbitmq
    - mode: 0644
    - watch_in:
      - service: rabbitmq-server

manage-rabbitmq-consul-cert:
  file.managed:
    - name: /etc/rabbitmq/ssl/consul_cert.pem
    - contents_pillar: 'consul:cert.pem'
    - contents_newline: False
    - user: rabbitmq
    - group: rabbitmq
    - mode: 0644
    - watch_in:
      - service: rabbitmq-server

manage-rabbitmq-consul-key:
  file.managed:
    - name: /etc/rabbitmq/ssl/consul_privkey.pem
    - contents_pillar: 'consul:key.pem'
    - contents_newline: False
    - user: rabbitmq
    - group: rabbitmq
    - mode: 0640
    - watch_in:
      - service: rabbitmq-server

manage-rabbitmq-erlang-cookie:
  file.managed:
    - name: /var/lib/rabbitmq/.erlang.cookie
    - contents:
      - {{ pillar['rabbitmq']['erlang_cookie'] }}
    - contents_newline: False
    - user: rabbitmq
    - group: rabbitmq
    - mode: 0400
    - watch_in:
      - service: rabbitmq-server

{% for plugin in pillar.get('rabbitmq', {}).get('plugins', ['rabbitmq_management']) %}
manage-rabbitmq-plugin-{{ plugin }}:
  rabbitmq_plugin.enabled:
    - name: {{ plugin }}
    - watch_in:
      - service: rabbitmq-server
{% endfor %}

# Do not start rabbitmq-server until the clock is synced and Consul is ready.
manage-rabbitmq-override:
  file.managed:
    - name: /etc/systemd/system/rabbitmq-server.service.d/override.conf
    - source: salt://rabbitmq-server/override.conf
    - user: root
    - group: root
    - mode: 0644
    - dir_mode: 0755
    - makedirs: True

  module.run:
    - service.systemctl_reload:
    - onchanges:
      - file: manage-rabbitmq-override

manage-rabbitmq-ha-policy:
  rabbitmq_policy.present:
    - name: HA
    - pattern: '^(?!amq\.).*'
    - definition: '{"ha-mode": "exactly", "ha-params": 2, "ha-sync-mode": "automatic"}'

manage-rabbitmq-ttl-policy:
  rabbitmq_policy.present:
    - name: TTL
    - pattern: 'notifications*'
    - definition: '{"message-ttl": 3600000}'

{% for user, data in pillar.get('rabbitmq', {}).get('users', {}).items() %}
manage-rabbitmq-user-{{ user }}:
  rabbitmq_user.present:
    - name: {{ user }}
    - password: {{ data['password'] }}
    - force: False
    - tags: {{ data.get('tags', None) | yaml }}
    - perms: {{ data['perms'] }}
    - runas: rabbitmq
{% endfor %}
