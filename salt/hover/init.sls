{% for domain, options in pillar.get('hover', {}).items() %}
{% if 'a_records' in options and options['a_records'] is mapping %}
{% for hostname in options['a_records'].get('hosts', ['@', '*']) %}
manage-{{ domain.replace('.', '_') }}-a-records-{{ loop.index }}:
  module.run:
    - name: hover.put_a_aaaa_records
    - domain: {{ domain }}
    - ip_address: {{ grains.ip4_interfaces[options['a_records']['interface']][0] }}
    - record_type: A
    - hostname: '{{ hostname }}'
{% endfor %}
{% endif %}

{% if 'aaaa_records' in options and options['aaaa_records'] is mapping %}
{% for hostname in options['aaaa_records'].get('hosts', ['@', '*']) %}
manage-{{ domain.replace('.', '_') }}-aaaa-records-{{ loop.index }}:
  module.run:
    - name: hover.put_a_aaaa_records
    - domain: {{ domain }}
    - ip_address: {{ grains.ip6_interfaces[options['aaaa_records']['interface']][0] }}
    - record_type: AAAA
    - hostname: '{{ hostname }}'
{% endfor %}
{% endif %}
{% endfor %}

schedule-hover-sync:
  schedule.present:
    - function: state.sls
    - job_args:
      - hover
    - cron: '{{ pillar['hover']['schedule'] }}'
