{% if not salt['file.file_exists']('/usr/local/bin/consul') or
      salt['file.stats']('/usr/local/bin/consul').get('mode', '') | int != 755 %}
{% set version = {} %}
{% else %}
{% set version = salt['cmd.run']('/usr/local/bin/consul version -format json') | load_json %}
{% endif %}

include:
  - consul.package

manage-consul-autocompletion:
  file.managed:
    - name: /etc/bash_completion.d/consul.bash
    - contents: complete -C /usr/local/bin/consul consul
    - user: root
    - group: root
    - mode: 0755
    - makedirs: True

manage-consul-user:
  group.present:
    - name: consul
    - system: True

  user.present:
    - name: consul
    - groups:
      - consul
    - home: /etc/consul.d
    - createhome: False
    - shell: /bin/false
    - system: True

manage-consul-artifacts-directory:
  file.directory:
    - name: /etc/consul
    - user: root
    - group: consul
    - mode: 0750

manage-consul-configuration:
  file.managed:
    - name: /etc/consul.d/consul.hcl
    - source: salt://consul/consul.hcl.jinja
    - template: jinja
    - user: root
    - group: consul
    - mode: 0640
    - dir_mode: 0755
    - makedirs: True

{% if 'consul-server' in grains.get('roles', []) %}
{% set role = 'server' %}
manage-consul-server-configuration:
  file.managed:
    - name: /etc/consul.d/server.hcl
    - source: salt://consul/server.hcl.jinja
    - template: jinja
    - user: root
    - group: consul
    - mode: 0640
    - watch_in:
      - service: manage-consul
{% else %}
{% set role = 'client' %}
{% endif %}

manage-consul-server-cacert:
  file.managed:
    - name: /etc/consul/{{ pillar['consul']['site']['domain'] }}-agent-ca.pem
    - contents_pillar: 'consul:cacert.pem'
    - contents_newline: False
    - user: root
    - group: consul
    - mode: 0644
    - watch_in:
      - service: manage-consul

manage-consul-{{ role }}-cert:
  file.managed:
    - name: /etc/consul/{{ role }}-{{ pillar['consul']['site']['domain'] }}.pem
    - contents_pillar: 'consul:cert.pem'
    - contents_newline: False
    - user: root
    - group: consul
    - mode: 0644
    - watch_in:
      - service: manage-consul

manage-consul-{{ role }}-key:
  file.managed:
    - name: /etc/consul/{{ role }}-{{ pillar['consul']['site']['domain'] }}-key.pem
    - contents_pillar: 'consul:key.pem'
    - contents_newline: False
    - user: root
    - group: consul
    - mode: 0640
    - watch_in:
      - service: manage-consul

manage-consul-cli-profile:
  file.managed:
    - name: /etc/profile.d/consul.sh
    - source: salt://consul/profile.jinja
    - template: jinja
    - user: root
    - group: root
    - mode: 0644

manage-consul-cli-cert:
  file.managed:
    - name: /etc/consul/cli-{{ pillar['consul']['site']['domain'] }}.pem
    - contents_pillar: 'consul:cli-cert.pem'
    - contents_newline: False
    - user: root
    - group: consul
    - mode: 0644

manage-consul-cli-key:
  file.managed:
    - name: /etc/consul/cli-{{ pillar['consul']['site']['domain'] }}-key.pem
    - contents_pillar: 'consul:cli-key.pem'
    - contents_newline: False
    - user: root
    - group: consul
    - mode: 0640

manage-consul:
  file.managed:
    - name: /etc/systemd/system/consul.service
    - source: salt://consul/consul.service.jinja
    - template: jinja
    - user: root
    - group: root
    - mode: 0644

  module.run:
    - service.systemctl_reload:
    - onchanges:
      - file: manage-consul

  service.running:
    - name: consul
    - enable: True
    - restart: True
    - watch:
      - file: manage-consul
      - file: manage-consul-configuration
