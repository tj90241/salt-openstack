manage-apparmor:
  pkg.latest:
    - pkgs:
      - apparmor
      - apparmor-utils
    - refresh: False
