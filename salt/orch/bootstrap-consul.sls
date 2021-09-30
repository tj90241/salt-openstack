resolve-consul-requirements:
  salt.state:
    - tgt: 'N@salt-masters or N@consul-servers'
    - tgt_type: compound
    - sls:
      - gai
      - hosts
      - consul.package

generate-consul-certs:
  salt.state:
    - tgt: salt-masters
    - tgt_type: nodegroup
    - sls:
      - consul.ca

distribute-consul-certs:
  salt.function:
    - name: saltutil.refresh_pillar
    - tgt: 'N@salt-masters or N@consul-servers'
    - tgt_type: compound

bootstrap-consul-servers:
  salt.state:
    - tgt: 'N@salt-masters or N@consul-servers'
    - tgt_type: compound
    - sls:
      - consul

wait-for-consul-cluster:
  salt.function:
    - tgt: salt-masters
    - tgt_type: nodegroup
    - name: test.sleep
    - arg:
        - 10

bootstrap-consul-acl:
  salt.state:
    - tgt: salt-masters
    - tgt_type: nodegroup
    - sls:
      - consul.bootstrap

author-consul-acl-policy:
  salt.state:
    - tgt: salt-masters
    - tgt_type: nodegroup
    - sls:
      - consul.policy

generate-consul-acl-tokens:
  salt.state:
    - tgt: salt-masters
    - tgt_type: nodegroup
    - sls:
      - consul.tokens

create-consul-acl-token-pillars:
  salt.state:
    - tgt: salt-masters
    - tgt_type: nodegroup
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
