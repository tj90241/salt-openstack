salt:
  api:
    host: 127.0.1.1
    port: 4443
    root_prefix: /salt

  grains:
    roles:
      - salt-master

  master:
    pillar_source_merging_strategy: recurse
    top_file_merging_strategy: same
