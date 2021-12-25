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

{% for minion_name in salt['minion.list']()['minions'] %}
{% set host = grains.host if minion_name == grains.id else minion_name %}

{% if 'node-' + host not in policy_list %}
{% if minion_name in pillar['consul']['site']['server_fqdns'].values() | list %}
{% from "consul/policies/consul-server.jinja" import policy with context %}
{% else %}
{% if host in pillar.get('roles', {}).get('apt-server', []) %}
{% from "consul/policies/apt-server.jinja" import policy with context %}
{% elif host in pillar.get('roles', {}).get('git-server', []) %}
{% from "consul/policies/git-server.jinja" import policy with context %}
{% elif host in pillar.get('roles', {}).get('jenkins-server', []) %}
{% from "consul/policies/jenkins-server.jinja" import policy with context %}
{% else %}
{% from "consul/policies/default.jinja" import policy with context %}
{% endif %}
{% endif %}
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
