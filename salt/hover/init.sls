{% if pillar.get('hover', {}).keys() | list not in [[], ['schedule']] %}
schedule-hover-sync:
  schedule.present:
    - function: state.sls
    - job_args:
      - hover.sync
    - cron: '{{ pillar['hover']['schedule'] }}'
{% endif %}
