include:
  - .pkgrepo

manage-docker:
  pkg.installed:
    - name: docker-ce
    - refresh: False
    - version: latest

  file.recurse:
    - name: /etc/docker
    - source: salt://docker/docker.jinja
    - template: jinja
    - user: root
    - group: root
    - clean: False
    - dir_mode: 0755
    - file_mode: 0644
    - exclude_pat: key.json

  service.running:
    - name: docker
    - enable: True
    - watch:
      - pkg: manage-docker
      - file: manage-docker
{#
manage-docker-serverkey:
  file.managed:
    - name: /var/docker/serverkey.pem
    - contents_pillar: 'consul:key.pem'
    - contents_newline: False
    - user: root
    - group: docker
    - makedirs: True
    - dir_mode: 0750
    - file_mode: 0640
    - watch_in:
      - service: manage-docker
#}
