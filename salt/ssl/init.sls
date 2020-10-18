{% set ssl = pillar.get('ssl', {}) %}

{% if 'cert.pem' in ssl %}
manage-{{ grains.id }}-cert-pem:
  file.managed:
    - name: /etc/ssl/certs/{{ grains.id }}-cert.pem
    - contents_pillar: 'ssl:cert.pem'
    - contents_newline: False
    - user: root
    - group: root
    - mode: 0644
{% endif %}

{% if 'chain.pem' in ssl %}
manage-{{ grains.id }}-chain-pem:
  file.managed:
    - name: /etc/ssl/certs/{{ grains.id }}-chain.pem
    - contents_pillar: 'ssl:chain.pem'
    - contents_newline: False
    - user: root
    - group: root
    - mode: 0644
{% endif %}

{% if 'cert.pem' in ssl and 'chain.pem' in ssl %}
manage-{{ grains.id }}-fullchain-pem:
  file.managed:
    - name: /etc/ssl/certs/{{ grains.id }}-fullchain.pem
    - contents_pillar:
        - 'ssl:cert.pem'
        - 'ssl:chain.pem'
    - contents_newline: False
    - user: root
    - group: root
    - mode: 0644
{% endif %}

{% if 'privkey.pem' in ssl and 'fullchain.pem' in ssl %}
manage-{{ grains.id }}-pemfile-pem:
  file.managed:
    - name: /etc/ssl/private/{{ grains.id }}-pemfile.pem
    - contents_pillar:
        - 'ssl:privkey.pem'
        - 'ssl:fullchain.pem'
    - contents_newline: False
    - user: root
    - gruop: root
    - mode: 0640
{% endif %}

{% if 'privkey.pem' in ssl %}
manage-{{ grains.id }}-privkey-pem:
  file.managed:
    - name: /etc/ssl/private/{{ grains.id }}-privkey.pem
    - contents_pillar: 'ssl:privkey.pem'
    - contents_newline: False
    - user: root
    - group: root
    - mode: 0640
{% endif %}
