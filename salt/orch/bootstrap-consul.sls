bootstrap-consul-ca:
  salt.state:
    - tgt: 'roles:salt-master'
    - tgt_type: grain
    - sls:
      - gai
      - hosts
      - consul.package
      - consul.ca

distribute-consul-certs:
  salt.function:
    - name: saltutil.refresh_pillar
    - tgt: 'G@roles:salt-master or G@roles:consul-server'
    - tgt_type: compound

bootstrap-consul-servers:
  salt.state:
    - tgt: 'G@roles:salt-master or G@roles:consul-server'
    - tgt_type: compound
    - sls:
      - gai
      - hosts
      - consul

bootstrap-consul-acls-policy:
  salt.state:
    - tgt: 'roles:salt-master'
    - tgt_type: grain
    - sls:
      - consul.bootstrap
      - consul.policy
      - consul.tokens
      - consul.token_pillars

distribute-consul-certs-and-tokens:
  salt.function:
    - name: saltutil.refresh_pillar
    - tgt: '*'

deploy-consul:
  salt.state:
    - tgt: '*'
    - sls:
      - consul

