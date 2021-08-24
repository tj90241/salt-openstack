{%- if not pillar.get('consul', {}).get('acl', {}).get('bootstrap_token') %}
{%- set bootstrap_response = salt['http.query'](
  'https://' + grains.fqdn + ':8501/v1/acl/bootstrap',
  method='PUT', 
  decode=True,
  decode_type='json',
  ca_bundle='/etc/consul.d/' + pillar['consul']['site']['domain'] + '-agent-ca.pem',
  cert=[
    '/etc/consul.d/client-' + pillar['consul']['site']['domain'] + '.pem',
    '/etc/consul.d/client-' + pillar['consul']['site']['domain'] + '-key.pem',
  ]
) -%}

manage-consul-acl-bootstrap-token:
  file.managed:
    - name: /srv/pillar/consul/bootstrap.sls
    - contents: |
        consul:
          acl:
            bootstrap_token: "{{ bootstrap_response['dict']['SecretID'] }}"
    - user: root
    - group: root
    - mode: 0644

  module.run:
    - saltutil.refresh_pillar:
{% else %}
{% set bootstrap_response = {"dict": {"SecretID": pillar['consul']['acl']['bootstrap_token']}} %}

manage-consul-acl-bootstrap-token:
  test.succeed_without_changes:
    - name: Consul ACL bootstrap token already exists
{% endif %}
