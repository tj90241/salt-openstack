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

{% for host in salt['minion.list']()['minions'] %}
{% set token = token_query['dict'] | selectattr('Description', '==', 'node-' + host) | map(attribute='SecretID') | first %}
manage-consul-node-{{ host }}-token-pillar:
  file.managed:
    - name: /etc/salt/file_tree_pillar/hosts/{{ host }}/consul/token
    - contents: {{ token.strip() }}
    - user: root
    - group: root
    - mode: 0640
    - show_changes: False
{% endfor %}
