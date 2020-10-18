salt:
  grains:
    mgmt_interface: eth0

    roles:
      - salt-master

  master:
    file_roots:
      base:
        - /srv/salt

    pillar_roots:
      base:
        - /srv/pillar

    ext_pillar:
      - file_tree:
          root_dir: /etc/salt/file_tree_pillar
          follow_dir_links: True
          keep_newline: False
