leave-consul-cluster:
  cmd.run:
    - name: /usr/local/bin/consul leave
    - env:
      - CONSUL_CACERT: /etc/consul/consul.stachecki.net-agent-ca.pem
      - CONSUL_CLIENT_CERT: /etc/consul/cli-consul.stachecki.net.pem
      - CONSUL_CLIENT_KEY: /etc/consul/cli-consul.stachecki.net-key.pem
{% if 'token' in pillar['consul'] %}
      - CONSUL_HTTP_TOKEN: "{{ pillar['consul']['token'].strip() }}"
{% endif %}
      - CONSUL_HTTP_ADDR: "127.0.0.1:8501"
      - CONSUL_HTTP_SSL: "true"
