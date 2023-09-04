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

{% set default_policy_token = token_query['dict'] | selectattr('Description', '==', 'default-policy') | map(attribute='SecretID') | first %}
manage-consul-default-policy-token-pillar:
  file.managed:
    - name: /srv/pillar/consul/tokens.sls
    - contents: |
        consul:
          tokens:
            default: {{ default_policy_token.strip() }}
    - user: root
    - group: salt
    - mode: 0640
    - show_changes: False

{% for minion_name in salt['minion.list']()['minions'] %}
{% set host = grains.host if minion_name == grains.id else minion_name %}
{% set agent_policy_token = token_query['dict'] | selectattr('Description', '==', 'node-' + host) | map(attribute='SecretID') | first %}
manage-consul-node-{{ host }}-agent-policy-token-pillar:
  file.managed:
    - name: /etc/salt/file_tree_pillar/hosts/{{ minion_name }}/consul/token
    - contents: {{ agent_policy_token.strip() }}
    - user: root
    - group: salt
    - mode: 0640
    - show_changes: False
{% endfor %}
