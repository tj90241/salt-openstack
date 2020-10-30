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
    - name: certbot certonly --cert-name '{{ minion }}' -d '{{ ','.join(options['domains']) }}' --rsa-key-size {{ options.get('rsa_key_size', 4096) }} --email '{{ options['email'] }}' --non-interactive --agree-tos --manual --manual-public-ip-logging-ok --preferred-challenges=dns --manual-auth-hook /usr/local/sbin/hover-dns-challenge-hook; rm -v /usr/local/sbin/hover-dns-challenge-hook

{% if 'salt-master' in grains.get('roles', []) %}
certbot-symlink-{{ minion}}-cert:
  file.symlink:
    - name: /etc/salt/file_tree_pillar/hosts/{{ minion }}/ssl
    - target: /etc/letsencrypt/live/{{ minion }}
    - user: root
    - group: root
    - mode: 0700
    - makedirs: True
    - force: True
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
