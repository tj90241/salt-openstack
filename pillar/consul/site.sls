consul:
  site:
    datacenter: salt-openstack
    domain: consul.example.com

    {# server_fqdn: minion_name #}
    server_fqdns:
      leader1.openstack.example.com: leader1
      leader2.openstack.example.com: leader2
      leader3.openstack.example.com: leader3
