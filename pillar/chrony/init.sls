chrony:
  server_defaults:
    iburst: True

  {# TODO: Not a great default; definitely a "works for me" thing. #}
  servers:
    - {{ grains.ip4_gw }}:
        minpoll: 1
        maxpoll: 3
