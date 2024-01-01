{% for minion_name in salt['minion.list']()['minions'] %}
manage-minion-{{ minion_name }}-dhparams-dir:
  file.directory:
    - name: /etc/salt/file_tree_pillar/hosts/{{ minion_name }}/openssl
    - user: root
    - group: salt
    - mode: 0750
    - makedirs: True
{% endfor %}

{% for minion_name in salt['minion.list']()['minions'] %}
manage-minion-{{ minion_name }}-dhparams:
  file.managed:
    - name: /etc/salt/file_tree_pillar/hosts/{{ minion_name }}/openssl/dhparam-{{ pillar['openssl']['dhparam_bits'] }}.pem
    - user: root
    - group: salt
    - mode: 0640
    - replace: False

  cmd.run:
    - name: openssl dhparam -out /etc/salt/file_tree_pillar/hosts/{{ minion_name }}/openssl/dhparam-{{ pillar['openssl']['dhparam_bits'] }}.pem {{ pillar['openssl']['dhparam_bits'] }}
    - onchanges:
      - file: manage-minion-{{ minion_name }}-dhparams
{% endfor %}
