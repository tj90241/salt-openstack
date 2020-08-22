manage-man-db:
  pkg.installed:
    - refresh: False
    - version: latest
    - pkgs:
      - man-db
      - manpages-dev
