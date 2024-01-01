{% for minion_name in salt['minion.list']()['minions'] %}
manage-ssh-minion-{{ minion_name }}-hostkeys:
  file.directory:
    - name: /etc/salt/file_tree_pillar/hosts/{{ minion_name }}/ssh/etc/ssh
    - user: root
    - group: salt
    - mode: 0750
    - makedirs: True

  cmd.run:
    - name: ssh-keygen -Af /etc/salt/file_tree_pillar/hosts/{{ minion_name }}/ssh
{% endfor %}

{% for minion_name in salt['minion.list']()['minions'] %}
manage-minion-{{ minion_name }}-moduli:
  file.managed:
    - name: /etc/salt/file_tree_pillar/hosts/{{ minion_name }}/ssh/etc/ssh/moduli
    - user: root
    - group: salt
    - mode: 0640
    - replace: False

  cmd.run:
    - name: |
        ssh-keygen -M generate -O bits=2048 /etc/salt/file_tree_pillar/hosts/{{ minion_name }}/ssh/moduli.candidates;
        ssh-keygen -M screen -f /etc/salt/file_tree_pillar/hosts/{{ minion_name }}/ssh/moduli.candidates \
		/etc/salt/file_tree_pillar/hosts/{{ minion_name }}/ssh/etc/ssh/moduli;
        rm -fv /etc/salt/file_tree_pillar/hosts/{{ minion_name }}/ssh/moduli.candidates

    - onchanges:
      - file: manage-minion-{{ minion_name }}-moduli

manage-minion-{{ minion_name }}-moduli-candidates:
  file.absent:
    - name: /etc/salt/file_tree_pillar/hosts/{{ minion_name }}/ssh/moduli.candidates
{% endfor %}

{% for minion_name in salt['minion.list']()['minions'] %}
manage-ssh-minion-{{ minion_name }}-ownership:
  file.directory:
    - name: /etc/salt/file_tree_pillar/hosts/{{ minion_name }}/ssh/etc/ssh
    - user: root
    - group: salt
    - file_mode: 0640
    - dir_mode: 0750
    - makedirs: False
    - recurse:
      - user
      - group
      - mode
{% endfor %}
