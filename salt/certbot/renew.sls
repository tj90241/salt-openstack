{% set key_type = pillar.get('certbot', {}).get('key-type', 'ecdsa') %}
{% for minion, options in pillar.get('certbot', {}).get('certs', {}).items() %}
{% if options['challenge'] == 'hover-dns' %}
certbot-renew-{{ minion}}-cert:
  file.managed:
    - name: /usr/local/sbin/hover-dns-challenge-hook
    - source: salt://certbot/hover-dns-challenge-hook.jinja
    - template: jinja
    - user: root
    - group: root
    - mode: 0755
    - context:
        hover_domain: {{ options['hover_domain'] }}

  cmd.run:
    - name: certbot certonly --cert-name '{{ minion }}' -d '{{ ','.join(options['domains']) }}'{% if key_type == 'rsa' %} --rsa-key-size {{ options.get('rsa_key_size', 4096) }}{% endif %}{% if key_type == 'ecdsa' %} --elliptic-curve={{ options.get('elliptic_curve', 'secp384r1') }}{% endif %} --email '{{ options['email'] }}' --non-interactive --agree-tos --manual --manual-public-ip-logging-ok --preferred-challenges=dns --manual-auth-hook /usr/local/sbin/hover-dns-challenge-hook; rm -v /usr/local/sbin/hover-dns-challenge-hook

{% if 'salt-masters' in pillar.get('nodegroups', []) %}
{% for cert in ['cert', 'chain', 'fullchain', 'privkey'] %}
ensure-{{ minion }}-{{ cert }}-exists-in-pillar:
  file.managed:
    - name: /etc/salt/file_tree_pillar/hosts/{{ minion }}/ssl/{{ cert }}.pem
    - source: /etc/letsencrypt/live/{{ minion }}/{{ cert }}.pem
    - user: root
    - group: salt
    - mode: {{ '0640' if cert == 'privkey' else '0644' }}
    - makedirs: True
    - dir_mode: 0750
{% endfor %}
{% endif %}
{% endif %}
{% endfor %}

certbot-refresh-pillar:
  module.run:
    - saltutil.refresh_pillar:

schedule-certbot-renewal:
  schedule.present:
    - function: state.sls
    - job_args:
      - certbot.renew
    - cron: '{{ pillar['certbot']['schedule'] }}'
