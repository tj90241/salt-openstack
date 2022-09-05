{% from 'rabbitmq-server/cluster.jinja' import
  rabbitmq_cluster_leader,
  rabbitmq_session_uuid
  with context %}

display_rabbitmq_session_results:
  test.succeed_without_changes:
    - name: "The cluster session lock is owned by {{ rabbitmq_cluster_leader }}"
