{% set domains = [] %}

{% for domain, options in pillar.get('hover', {}).items() %}
{% if 'session_token' in options and 'auth_token' in options and 'a_records' in options %}
{% do domains.append(domain) %}
{% endif %}
{% endfor %}

{% if domains | length > 0 %}
schedule-hover-sync:
  schedule.present:
    - function: state.sls
    - job_args:
      - hover.sync
    - cron: '{{ pillar['hover']['schedule'] }}'
{%- if 'splay' in pillar['hover'] %}
    - splay: {{ pillar['hover']['splay'] }}
{%- endif %}
{% else %}
schedule-hover-sync:
  schedule.absent:
    - function: state.sls
{% endif %}

{% if 'smtp-salt-alerts' in pillar %}
schedule-hover-ping:
  schedule.present:
    - function: state.sls
    - job_args:
      - hover.ping
    - cron: '{{ pillar['hover']['ping_schedule'] }}'
{%- if 'splay' in pillar['hover'] %}
    - splay: {{ pillar['hover']['splay'] }}
{%- endif %}
{% endif %}
