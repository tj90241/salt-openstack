{%- set policy_query = salt['http.query'](
  url='https://' + grains.fqdn + ':8501/v1/acl/policies',
  method='GET', 
  decode=True,
  decode_type='json',
  header_dict={"X-Consul-Token": pillar['consul']['acl']['bootstrap_token']},
  ca_bundle='/etc/consul/' + pillar['consul']['site']['domain'] + '-agent-ca.pem',
  cert=[
    '/etc/consul/client-' + pillar['consul']['site']['domain'] + '.pem',
    '/etc/consul/client-' + pillar['consul']['site']['domain'] + '-key.pem',
  ]
) -%}

{%- set policy_list = policy_query['dict'] | map(attribute='Name') | list %}

{% if 'default-policy' not in policy_list %}
{% from "consul/policies/default.jinja" import policy %}
create-consul-default-policy:
  module.run:
    - http.query:
      - url: "https://{{ grains.fqdn }}:8501/v1/acl/policy"
      - method: PUT
      - decode: True
      - decode_type: json
      - header_dict:
          X-Consul-Token: "{{ pillar['consul']['acl']['bootstrap_token'] }}"
      - ca_bundle: "/etc/consul/{{ pillar['consul']['site']['domain'] }}-agent-ca.pem"
      - cert:
        - "/etc/consul/client-{{ pillar['consul']['site']['domain'] }}.pem"
        - "/etc/consul/client-{{ pillar['consul']['site']['domain'] }}-key.pem"
      - data: '{{ policy }}'
{% endif %}

{# Agent policy needs the following Jinja variables loaded in the context. #}
{%- set consul_server_hosts = pillar['consul']['site']['server_fqdns'].values() %}
{%- set roles = pillar.get('roles', {}) %}

{% for minion_name in salt['minion.list']()['minions'] %}
{% set host = grains.host if minion_name == grains.id else minion_name %}
{% if 'node-' + host not in policy_list %}
{% from "consul/policies/agent.jinja" import policy with context %}
create-consul-node-{{ host }}-policy:
  module.run:
    - http.query:
      - url: "https://{{ grains.fqdn }}:8501/v1/acl/policy"
      - method: PUT
      - decode: True
      - decode_type: json
      - header_dict:
          X-Consul-Token: "{{ pillar['consul']['acl']['bootstrap_token'] }}"
      - ca_bundle: "/etc/consul/{{ pillar['consul']['site']['domain'] }}-agent-ca.pem"
      - cert:
        - "/etc/consul/client-{{ pillar['consul']['site']['domain'] }}.pem"
        - "/etc/consul/client-{{ pillar['consul']['site']['domain'] }}-key.pem"
      - data: '{{ policy }}'
{% endif %}
{% endfor %}
