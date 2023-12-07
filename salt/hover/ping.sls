{% set domains = [] %}

{% for domain, options in pillar.get('hover', {}).items() %}
{% if 'session_token' in options and 'auth_token' in options %}
{% do domains.append(domain) %}
test-hover-access-for-{{ domain.replace('.', '-') }}:
  module.run:
    - hover.get_records:
      - domain: {{ domain }}
    - onfail_in:
      - module: notify-of-failure
{% endif %}
{% endfor %}

{% if domains | length > 0 %}
notify-of-failure:
  module.run:
    - smtp.send_msg:
      - recipient: {{ pillar['smtp-salt-alerts']['smtp.sender'] }}
      - message: Failed to submit a test request to Hover's API endpoint
      - subject: '[CRITICAL] Hover API ping failed'
      - profile: smtp-salt-alerts
{% endif %}
