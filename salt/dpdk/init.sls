manage-dpdk:
  pkg.latest:
    - pkgs:
      - dpdk
      - python3-pyelftools
    - refresh: False
