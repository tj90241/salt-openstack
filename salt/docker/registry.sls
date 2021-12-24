manage-docker-registry:
  file.managed:
    - name: /etc/systemd/system/docker-registry.service
    - source: salt://docker/docker-registry.service.jinja
    - template: jinja
    - user: root
    - group: root
    - mode: 0644

  module.run:
    - service.systemctl_reload:
    - onchanges:
      - file: manage-docker-registry

  service.running:
    - name: docker-registry
    - enable: True
    - restart: True
    - watch:
      - module: manage-docker-registry
      - file: manage-docker-registry-fullchain-pem
      - file: manage-docker-registry-privkey-pem
      - file: manage-docker-registry-state

manage-docker-registry-fullchain-pem:
  file.managed:
    - name: /etc/docker-registry/{{grains.id }}-fullchain.pem
    - contents_pillar:
        - 'ssl:cert.pem'
        - 'ssl:chain.pem'
    - contents_newline: False
    - user: root
    - group: root
    - mode: 0644
    - dir_mode: 0755
    - makedirs: True

manage-docker-registry-privkey-pem:
  file.managed:
    - name: /etc/docker-registry/private/{{ grains.id }}-privkey.pem
    - contents_pillar: 'ssl:privkey.pem'
    - contents_newline: False
    - user: root
    - group: root
    - mode: 0640
    - dir_mode: 0750
    - makedirs: True

manage-docker-registry-state:
  file.directory:
    - name: /var/lib/docker-registry
    - user: root
    - group: root
    - mode: 0755

manage-docker-htpasswd-file:
  file.managed:
    - name: /etc/docker-registry/htpasswd
    - mode: 0640
    - user: root
    - group: root

{% for user, data in pillar['docker']['registry']['users'].items() %}
manage-docker-htpasswd-{{ user }}-user:
  webutil.user_exists:
    - name: {{ user }}
    - password: {{ data['password'] }}
    - htpasswd_file: /etc/docker-registry/htpasswd
    - update: True
    - options: B
    - require:
      - file: manage-docker-htpasswd-file
    - watch_in:
      - service: manage-docker-registry
{% endfor %}
