manage-python2:
  pkg.purged:
    - pkgs:
      - libpython-stdlib
      - libpython2-stdlib
      - libpython2.7-minimal
      - libpython2.7-stdlib
      - python2
      - python2-minimal
      - python2.7
      - python2.7-minimal
    - refresh: False
