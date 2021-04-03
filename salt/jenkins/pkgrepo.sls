manage-jenkins-repo:
  pkgrepo.managed:
    - humanname: Jenkins LTS Repo
    - file: /etc/apt/sources.list.d/jenkins.list
    - name: deb https://pkg.jenkins.io/debian-stable binary/
    - key_url: https://pkg.jenkins.io/debian-stable/jenkins.io.key
    - clean_file: True

  module.run:
    - pkg.refresh_db:
    - failhard: True
