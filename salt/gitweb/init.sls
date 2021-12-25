manage-gitweb:
  pkg.installed:
    - name: gitweb
    - refresh: False
    - version: latest

  file.managed:
    - name: /etc/gitweb.conf
    - source: salt://gitweb/gitweb.conf.jinja
    - template: jinja
    - user: root
    - group: root
    - mode: 0644

manage-gitweb-site:
  file.managed:
    - name: /etc/nginx/sites.d/gitweb.conf
    - source: salt://gitweb/site.conf.jinja
    - template: jinja
    - user: root
    - group: root

  service.running:
    - name: nginx
    - restart: True
    - watch:
      - file: manage-gitweb-site

manage-consul-gitweb:
  file.managed:
    - name: /etc/consul.d/git.json
    - source: salt://gitweb/consul.json.jinja
    - template: jinja
    - user: consul
    - group: consul
    - mode: 0640

  service.running:
    - name: consul
    - restart: True
    - watch:
      - file: manage-consul-gitweb
