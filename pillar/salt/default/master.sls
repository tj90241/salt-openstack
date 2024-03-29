salt:
  api:
    root_prefix: /salt

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
          keep_newline: True

      - nodegroups:
          pillar_name: nodegroups
