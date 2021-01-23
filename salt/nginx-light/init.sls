manage-nginx-sites_d-directory:
  file.directory:
    - name: /etc/nginx/sites.d
    - user: root
    - group: root
    - mode: 0755
    - makedirs: True

manage-nginx-light:
  pkg.installed:
    - name: nginx-light
    - refresh: False
    - version: latest

  file.managed:
    - name: /etc/default/nginx
    - source: salt://nginx-light/default
    - user: root
    - group: root
    - mode: 0644
    - require:
      - pkg: manage-nginx-light

  service.running:
    - name: nginx
    - enable: True
    - restart: True
    - watch:
      - pkg: manage-nginx-light
      - file: manage-nginx-light
      - file: manage-nginx-configuration

manage-nginx-configuration:
  file.recurse:
    - name: /etc/nginx
    - source: salt://nginx-light/nginx.jinja
    - template: jinja
    - user: root
    - group: root
    - dir_mode: 0755
    - file_mode: 0644

{% for dir in ['conf.d', 'modules-available', 'modules-enabled', 'sites-available', 'sites-enabled'] %}
manage-nginx-{{ dir.replace('.', '_') }}:
  file.absent:
    - name: /etc/nginx/{{ dir }}
{% endfor %}
