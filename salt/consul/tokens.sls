{%- set token_query = salt['http.query'](
  url='https://' + grains.fqdn + ':8501/v1/acl/tokens',
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

{%- set token_list = token_query['dict'] | map(attribute='Description') | list %}

{% for minion_name in salt['minion.list']()['minions'] %}
{% set host = grains.host if minion_name == grains.id else minion_name %}

{% if 'node-' + host not in token_list %}
{% set token_data = {
  'Description': 'node-' + host,
  'Policies': [{'Name': 'node-' + host}],
  'Local': true
} %}

create-consul-node-{{ host }}-token:
  module.run:
    - http.query:
      - url: "https://{{ grains.fqdn }}:8501/v1/acl/token"
      - method: PUT
      - decode: True
      - decode_type: json
      - header_dict:
          X-Consul-Token: "{{ pillar['consul']['acl']['bootstrap_token'] }}"
      - ca_bundle: "/etc/consul/{{ pillar['consul']['site']['domain'] }}-agent-ca.pem"
      - cert:
        - "/etc/consul/client-{{ pillar['consul']['site']['domain'] }}.pem"
        - "/etc/consul/client-{{ pillar['consul']['site']['domain'] }}-key.pem"
      - data: '{{ token_data | json }}'
{% endif %}
{% endfor %}
