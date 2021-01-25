isc-dhcp-server:
  authoritative: True

  defaults:
    default_lease_time: 600
    deny_client_updates: True
    deny_unknown_clients: True
    max_lease_time: 7200
