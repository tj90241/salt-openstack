manage-ssh:
  pkg.installed:
    - name: ssh
    - refresh: False
    - version: latest

  service.enabled:
    - name: ssh

manage-ssh-override:
  file.managed:
    - name: /etc/systemd/system/ssh.service.d/override.conf
    - source: salt://ssh/override.conf
    - user: root
    - group: root
    - mode: 0644
    - dir_mode: 0755
    - makedirs: True

  module.run:
    - service.systemctl_reload:
    - onchanges:
      - file: manage-ssh-override

{% for key_type in ['ecdsa', 'ed25519', 'rsa'] %}
manage-{{ key_type }}-public-key:
  file.managed:
    - name: /etc/ssh/ssh_host_{{ key_type }}_key.pub
    - contents_pillar: 'ssh:etc:ssh:ssh_host_{{ key_type }}_key.pub'
    - user: root
    - group: root
    - mode: '0644'

manage-{{ key_type }}-private-key:
  file.managed:
    - name: /etc/ssh/ssh_host_{{ key_type }}_key
    - contents_pillar: 'ssh:etc:ssh:ssh_host_{{ key_type }}_key'
    - user: root
    - group: root
    - mode: '0600'
{% endfor %}
