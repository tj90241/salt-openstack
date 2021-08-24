{%- set policy_query = salt['http.query'](
  url='https://' + grains.fqdn + ':8501/v1/acl/policies',
  method='GET', 
  decode=True,
  decode_type='json',
  header_dict={"X-Consul-Token": pillar['consul']['acl']['bootstrap_token']},
  ca_bundle='/etc/consul.d/' + pillar['consul']['site']['domain'] + '-agent-ca.pem',
  cert=[
    '/etc/consul.d/client-' + pillar['consul']['site']['domain'] + '.pem',
    '/etc/consul.d/client-' + pillar['consul']['site']['domain'] + '-key.pem',
  ]
) -%}

{%- set policy_list = policy_query['dict'] | map(attribute='Name') | list %}

{% for host in salt['minion.list']()['minions'] %}
{% if 'node-' + host not in policy_list %}
{% from "consul/policies/default.jinja" import policy with context %}
create-consul-node-{{ host }}-policy:
  module.run:
    - http.query:
      - url: "https://{{ grains.fqdn }}:8501/v1/acl/policy"
      - method: PUT
      - decode: True
      - decode_type: json
      - header_dict:
          X-Consul-Token: "{{ pillar['consul']['acl']['bootstrap_token'] }}"
      - ca_bundle: "/etc/consul.d/{{ pillar['consul']['site']['domain'] }}-agent-ca.pem"
      - cert:
        - "/etc/consul.d/client-{{ pillar['consul']['site']['domain'] }}.pem"
        - "/etc/consul.d/client-{{ pillar['consul']['site']['domain'] }}-key.pem"
      - data: '{{ policy }}'
{% endif %}
{% endfor %}
