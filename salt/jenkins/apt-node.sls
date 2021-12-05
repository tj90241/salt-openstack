manage-jenkins-group:
  group.present:
    - name: {{ pillar['jenkins']['apt-node']['user']['name'] }}
    - system: True

manage-jenkins-user:
  user.present:
    - name: {{ pillar['jenkins']['apt-node']['user']['name'] }}
    - password: {{ pillar['jenkins']['apt-node']['user']['password'] }}
    - fullname: Jenkins CI
    - shell: /bin/dash
    - home: {{ pillar['jenkins']['remote_dir'] }}
    - system: True
    - groups:
      - {{ pillar['jenkins']['apt-node']['user']['name'] }}

manage-jenkins-keypair:
  file.managed:
    - name: {{ pillar['jenkins']['remote_dir'] }}/.ssh/authorized_keys
    - contents_pillar: jenkins:publish:keypair:public
    - contents_newline: False
    - user: {{ pillar['jenkins']['apt-node']['user']['name'] }}
    - group: {{ pillar['jenkins']['apt-node']['user']['name'] }}
    - mode: 0644
    - dir_mode: 0755
    - makedirs: True

manage-jenkins-publish-directory:
  file.directory:
    - name: {{ pillar['jenkins']['remote_dir'] }}
    - user: {{ pillar['jenkins']['apt-node']['user']['name'] }}
    - group: {{ pillar['jenkins']['apt-node']['user']['name'] }}

{% for project in ['ceph', 'galera', 'hostap', 'linux', 'mariadb', 'openvswitch'] %}
manage-jenkins-publish-{{ project }}-directory:
  file.directory:
    - name: {{ pillar['jenkins']['remote_dir'] }}/{{ project }}
    - user: {{ pillar['jenkins']['apt-node']['user']['name'] }}
    - group: {{ pillar['jenkins']['apt-node']['user']['name'] }}
{% endfor %}
