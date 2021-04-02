manage-haproxy:
  pkg.installed:
    - name: haproxy
    - refresh: False
    - version: latest

  file.managed:
    - name: /etc/default/haproxy
    - source: salt://haproxy/default
    - user: root
    - group: root
    - mode: 0644

  service.running:
    - name: haproxy
    - enable: True
    - reload: True
    - watch:
      - pkg: haproxy
      - file: manage-haproxy
      - file: manage-haproxy-d
      - file: manage-haproxy-configuration
      - file: manage-haproxy-ssl-cert

manage-haproxy-d:
  file.directory:
    - name: /etc/haproxy/haproxy.d
    - user: root
    - group: haproxy
    - mode: 0755

manage-haproxy-configuration:
  file.managed:
    - name: /etc/haproxy/haproxy.cfg
    - source: salt://haproxy/haproxy.cfg.jinja
    - template: jinja
    - user: root
    - group: root
    - mode: 0644

manage-haproxy-ssl-cert:
  file.managed:
    - name: /etc/haproxy/{{ grains.id }}.pem
    - contents_pillar:
        - ssl:fullchain.pem
        - ssl:privkey.pem
    - contents_newline: False
    - template: jinja
    - user: root
    - group: haproxy
    - mode: 0640
