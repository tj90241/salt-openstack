resolve-consul-requirements:
  salt.state:
    - tgt: 'G@roles:salt-master or G@roles:consul-server'
    - tgt_type: compound
    - sls:
      - gai
      - hosts
      - consul.package

generate-consul-certs:
  salt.state:
    - tgt: 'roles:salt-master'
    - tgt_type: grain
    - sls:
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
      - consul

wait-for-consul-cluster:
  salt.function:
    - tgt: 'roles:salt-master'
    - tgt_type: grain
    - name: test.sleep
    - arg:
        - 10

bootstrap-consul-acl:
  salt.state:
    - tgt: 'roles:salt-master'
    - tgt_type: grain
    - sls:
      - consul.bootstrap

author-consul-acl-policy:
  salt.state:
    - tgt: 'roles:salt-master'
    - tgt_type: grain
    - sls:
      - consul.policy

generate-consul-acl-tokens:
  salt.state:
    - tgt: 'roles:salt-master'
    - tgt_type: grain
    - sls:
      - consul.tokens

create-consul-acl-token-pillars:
  salt.state:
    - tgt: 'roles:salt-master'
    - tgt_type: grain
    - sls:
      - consul.token_pillars

distribute-consul-certs-and-tokens:
  salt.function:
    - name: saltutil.refresh_pillar
    - tgt: '*'

deploy-consul-agents:
  salt.state:
    - tgt: '*'
    - sls:
      - consul
