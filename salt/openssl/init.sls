manage-openssl:
  pkg.installed:
    - name: openssl
    - refresh: False
    - version: latest

  file.managed:
    - name: /etc/ssl/openssl.cnf
    - source: salt://openssl/openssl.cnf.jinja
    - template: jinja
    - user: root
    - group: root
    - mode: 0644

manage-host-dhparams:
  file.managed:
    - name: /etc/ssl/dhparam-{{ pillar['openssl']['dhparam_bits'] }}.pem
    - user: root
    - group: root
    - mode: 0644
{% if pillar.get('openssl', {}).get('dhparam-' + pillar['openssl']['dhparam_bits'] | string + '.pem') == None %}
    - replace: False

  cmd.run:
    - name: openssl dhparam -out /etc/ssl/dhparam-{{ pillar['openssl']['dhparam_bits'] }}.pem {{ pillar['openssl']['dhparam_bits'] }}
    - onchanges:
      - file: manage-host-dhparams
{% else %}
    - contents_pillar: 'openssl:dhparam-{{ pillar['openssl']['dhparam_bits'] }}.pem'
{% endif %}
