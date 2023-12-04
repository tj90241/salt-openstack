manage-git-user:
  group.present:
    - name: git
    - system: True
    - addusers:
      - www-data

  user.present:
    - name: git
    - fullname: Git Role Account
    - groups:
      - git
    - home: /var/lib/git
    - shell: /usr/bin/git-shell
    - createhome: True
    - nologinit: True
    - system: True

  file.directory:
    - name: /var/lib/git
    - user: git
    - group: git
    - mode: 0750
