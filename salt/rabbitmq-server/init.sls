manage-rabbitmq-directory:
  file.directory:
    - name: /var/lib/rabbitmq
    - user: rabbitmq
    - group: rabbitmq
    - mode: 0755
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
      - file: /var/lib/rabbitmq
      - file: /var/lib/rabbitmq/mnesia
    - watch:
      - file: /etc/rabbitmq
      - file: /etc/default/rabbitmq-server
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

# Do not start rabbitmq-server until the clock is synced.
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

manage-rabbitmq-plugin-management:
  rabbitmq_plugin.enabled:
    - name: rabbitmq_management

manage-consul-rabbitmq:
  file.managed:
    - name: /etc/consul.d/rabbitmq.json
    - source: salt://rabbitmq-server/consul.json.jinja
    - template: jinja
    - user: consul
    - group: consul
    - mode: 0640

  service.running:
    - name: consul
    - restart: True
    - watch:
      - file: manage-consul-rabbitmq
