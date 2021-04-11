include:
{%- if 'jenkins-node-ceph' in grains.get('roles', []) %}
  - jenkins.requirements.ceph
{%- endif %}
{%- if 'jenkins-node-linux' in grains.get('roles', []) %}
  - jenkins.requirements.linux
{%- endif %}
{%- if 'jenkins-node-mariadb' in grains.get('roles', []) %}
  - jenkins.requirements.mariadb
{%- endif %}
{%- if 'jenkins-node-openvswitch' in grains.get('roles', []) %}
  - jenkins.requirements.openvswitch
{%- endif %}

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

manage-jenkins-keypair:
  file.managed:
    - name: /home/{{ pillar['jenkins']['node']['user']['name'] }}/.ssh/authorized_keys
    - contents_pillar: jenkins:controller:keypair:public
    - contents_newline: False
    - user: {{ pillar['jenkins']['node']['user']['name'] }}
    - group: {{ pillar['jenkins']['node']['user']['name'] }}
    - mode: 0644
    - dir_mode: 0755
    - makedirs: True

manage-jenkins-remote-directory:
  file.directory:
    - name: {{ pillar['jenkins']['remote_dir'] }}
    - user: {{ pillar['jenkins']['node']['user']['name'] }}
    - group: {{ pillar['jenkins']['node']['user']['name'] }}
    - mode: 0750
