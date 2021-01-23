salt:
  api:
    host: 127.0.1.1
    port: 4443
    root_prefix: /salt

  grains:
    host: 127.0.1.1
    port: 4443
    root_prefix: /salt
    mgmt_interface: eth0

    roles:
      - salt-master
