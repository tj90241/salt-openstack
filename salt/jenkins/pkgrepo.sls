manage-jenkins-repo:
  file.managed:
    - name: /etc/apt/trusted.gpg.d/jenkins.io-2023.asc
    - source: https://pkg.jenkins.io/debian-stable/jenkins.io-2023.key
    - source_hash: 840baa766ba913dd3681986635743fb5a01b56b1
    - user: root
    - group: root
    - mode: 0644

  pkgrepo.managed:
    - humanname: Jenkins LTS Repo
    - file: /etc/apt/sources.list.d/jenkins.list
    - name: deb https://pkg.jenkins.io/debian-stable binary/
    - clean_file: True

  module.run:
    - pkg.refresh_db:
    - failhard: True
