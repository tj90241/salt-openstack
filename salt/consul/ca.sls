manage-consul-ca-cert:
  file.directory:
    - name: /etc/consul
    - user: root
    - group: root
    - mode: 0600

  cmd.run:
    - name: >
        CACERTDIR=`mktemp -d` && cd "${CACERTDIR}" &&
        /usr/local/bin/consul tls ca create -days 30 -domain {{ pillar['consul']['site']['domain'] }}{% for server_fqdn in pillar['consul']['site']['server_fqdns'] %} -additional-name-constraint {{ server_fqdn }}{% endfor %} -additional-name-constraint consul.service.{{ pillar['consul']['site']['domain'] }} -name-constraint true &&
        mv -v {{ pillar['consul']['site']['domain'] }}-agent-ca.pem {{ pillar['consul']['site']['domain'] }}-agent-ca-key.pem /etc/consul &&
        cd /tmp && rm -rfv "${CACERTDIR}";

{# Consul servers... #}
{% for server_fqdn, minion_name in pillar['consul']['site']['server_fqdns'].items() %}
manage-consul-minion-{{ minion_name }}-cert:
  file.directory:
    - name: /etc/salt/file_tree_pillar/hosts/{{ minion_name }}/consul
    - user: root
    - group: root
    - mode: 0700
    - makedirs: True

  cmd.run:
    - name: >
        SERVERCERTDIR=`mktemp -d` && cd "${SERVERCERTDIR}" &&
        /usr/local/bin/consul tls cert create -server -days 30 -ca /etc/consul/{{ pillar['consul']['site']['domain'] }}-agent-ca.pem -key /etc/consul/{{ pillar['consul']['site']['domain'] }}-agent-ca-key.pem -dc {{ pillar['consul']['site']['datacenter'] }} -domain {{ pillar['consul']['site']['domain'] }} -additional-dnsname {{ server_fqdn }} -additional-dnsname consul.service.{{ pillar['consul']['site']['domain'] }} &&
        mv -v {{ pillar['consul']['site']['datacenter'] }}-server-{{ pillar['consul']['site']['domain'] }}-0.pem /etc/salt/file_tree_pillar/hosts/{{ minion_name }}/consul/cert.pem &&
        mv -v {{ pillar['consul']['site']['datacenter'] }}-server-{{ pillar['consul']['site']['domain'] }}-0-key.pem /etc/salt/file_tree_pillar/hosts/{{ minion_name }}/consul/key.pem &&
        /usr/local/bin/consul tls cert create -cli -days 30 -ca /etc/consul/{{ pillar['consul']['site']['domain'] }}-agent-ca.pem -key /etc/consul/{{ pillar['consul']['site']['domain'] }}-agent-ca-key.pem -dc {{ pillar['consul']['site']['datacenter'] }} -domain {{ pillar['consul']['site']['domain'] }} &&
        mv -v {{ pillar['consul']['site']['datacenter'] }}-cli-{{ pillar['consul']['site']['domain'] }}-0.pem /etc/salt/file_tree_pillar/hosts/{{ minion_name }}/consul/cli-cert.pem &&
        mv -v {{ pillar['consul']['site']['datacenter'] }}-cli-{{ pillar['consul']['site']['domain'] }}-0-key.pem /etc/salt/file_tree_pillar/hosts/{{ minion_name }}/consul/cli-key.pem &&
        cd /tmp && rm -rfv "${SERVERCERTDIR}";
{% endfor %}

{# Consul clients... #}
{% for minion_name in salt['minion.list']()['minions'] %}
{% if minion_name not in pillar['consul']['site']['server_fqdns'].values() %}
manage-consul-minion-{{ minion_name }}-cert:
  file.directory:
    - name: /etc/salt/file_tree_pillar/hosts/{{ minion_name }}/consul
    - user: root
    - group: root
    - mode: 0700
    - makedirs: True

  cmd.run:
    - name: >
        CLIENTCERTDIR=`mktemp -d` && cd "${CLIENTCERTDIR}" &&
        /usr/local/bin/consul tls cert create -client -days 30 -ca /etc/consul/{{ pillar['consul']['site']['domain'] }}-agent-ca.pem -key /etc/consul/{{ pillar['consul']['site']['domain'] }}-agent-ca-key.pem -dc {{ pillar['consul']['site']['datacenter'] }} -domain {{ pillar['consul']['site']['domain'] }} &&
        mv -v {{ pillar['consul']['site']['datacenter'] }}-client-{{ pillar['consul']['site']['domain'] }}-0.pem /etc/salt/file_tree_pillar/hosts/{{ minion_name }}/consul/cert.pem &&
        mv -v {{ pillar['consul']['site']['datacenter'] }}-client-{{ pillar['consul']['site']['domain'] }}-0-key.pem /etc/salt/file_tree_pillar/hosts/{{ minion_name }}/consul/key.pem &&
        cd /tmp && rm -rfv "${CLIENTCERTDIR}";
{% endif %}
{% endfor %}

manage-consul-domain-nodegroup-cacert:
  file.directory:
    - name: /etc/salt/file_tree_pillar/nodegroups/consul-domain/consul
    - user: root
    - group: root
    - mode: 0700
    - makedirs: True

  cmd.run:
    - name: >
        cp -v /etc/consul/{{ pillar['consul']['site']['domain'] }}-agent-ca.pem /etc/salt/file_tree_pillar/nodegroups/consul-domain/consul/cacert.pem
