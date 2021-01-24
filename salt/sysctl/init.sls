{%- for name, value in pillar.get('sysctl', {}).items() %}
manage-sysctl-{{ name }}:
  sysctl.present:
    - name: {{ name }}
    - value: {{ value }}
    - config: /etc/sysctl.d/local.conf
{%- endfor %}
