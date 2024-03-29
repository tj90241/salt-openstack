manage-jenkins-group:
  group.present:
    - name: {{ pillar['jenkins']['node']['user']['name'] }}
    - system: True

manage-jenkins-user:
  user.present:
    - name: {{ pillar['jenkins']['node']['user']['name'] }}
    - password: {{ pillar['jenkins']['node']['user']['password'] }}
    - fullname: Jenkins CI
    - shell: /bin/dash
    - home: /home/{{ pillar['jenkins']['node']['user']['name'] }}
    - system: True
    - groups:
      - {{ pillar['jenkins']['node']['user']['name'] }}
      - docker

manage-jenkins-controller-pubkey:
  file.managed:
    - name: /home/{{ pillar['jenkins']['node']['user']['name'] }}/.ssh/authorized_keys
    - contents_pillar: jenkins:controller:keypair:public
    - contents_newline: False
    - user: {{ pillar['jenkins']['node']['user']['name'] }}
    - group: {{ pillar['jenkins']['node']['user']['name'] }}
    - mode: 0644
    - dir_mode: 0755
    - makedirs: True

manage-jenkins-publish-privkey:
  file.managed:
    - name: /home/{{ pillar['jenkins']['node']['user']['name'] }}/.ssh/id_rsa
    - contents_pillar: jenkins:publish:keypair:private
    - contents_newline: False
    - user: {{ pillar['jenkins']['node']['user']['name'] }}
    - group: {{ pillar['jenkins']['node']['user']['name'] }}
    - mode: 0600
    - dir_mode: 0755
    - makedirs: True

manage-jenkins-remote-directory:
  file.directory:
    - name: {{ pillar['jenkins']['remote_dir'] }}
    - user: {{ pillar['jenkins']['node']['user']['name'] }}
    - group: {{ pillar['jenkins']['node']['user']['name'] }}
    - mode: 0750

{# Size up /tmp to a healthy portion of the build node's RAM, as GCC will #}
{# dump lots of temporary files here that would otherwise burn up the disk. #}
manage-jenkins-node-tmp:
  file.managed:
    - name: /etc/systemd/system/tmp.mount
    - source: salt://jenkins/tmp.mount.jinja
    - template: jinja
    - user: root
    - group: root
    - mode: 0644

  module.run:
    - service.systemctl_reload:
    - onchanges:
      - file: manage-jenkins-node-tmp

  service.enabled:
    - name: tmp.mount

manage-docker-registry-login:
  cmd.run:
    - name: /usr/bin/docker login -u jenkins --password-stdin 'https://registry.service.{{ pillar['consul']['site']['domain'] }}:443'
    - stdin: {{ pillar['docker']['registry']['users']['jenkins']['password'] }}
    - runas: jenkins
