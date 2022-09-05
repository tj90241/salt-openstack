{% from 'rabbitmq-server/cluster.jinja' import
  rabbitmq_cluster_leader,
  rabbitmq_session_uuid
  with context %}

{% if rabbitmq_cluster_leader == grains.id %}
release-rabbitmq-session-lock:
  module.run:
    - consul.session_release:
      - uuid: {{ rabbitmq_session_uuid }}
{% endif %}
