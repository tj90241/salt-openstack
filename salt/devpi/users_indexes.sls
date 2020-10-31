{% set have = salt['devpi.get_users_and_indexes']() %}
{% set want = pillar['devpi']['users'] %}

{# Delete users and indexes which should no longer exist. #}
{% for user, user_data in have.items() %}
{% if user not in want %}
devpi_user_{{ user }}_absent:
  devpi.user_absent:
    - name: {{ user }}
{% else %}
{% for index in user_data['indexes'] %}
{% if index not in want[user].get('indexes', []) %}
devpi_index_{{ user }}_{{ index }}_absent:
  devpi.index_absent:
    - name: {{ index }}
    - username: {{ user }}
{% endif %}
{% endfor %}
{% endif %}
{% endfor %}

{# Create users which should exist. #}
{% for user, user_data in want.items() %}
devpi_user_{{ user }}_exists:
  devpi.user_present:
    - name: {{ user }}
    - password: {{ user_data['password'] }}
{% if 'email' in user_data %}
    - email: {{ user_data['email'] }}
{% endif %}
{% for index, index_data in want[user].get('indexes', {}).items() %}
devpi_index_{{ user }}_{{ index }}_exists:
  devpi.index_present:
    - name: {{ index }}
    - username: {{ user }}
{% if 'bases' in index_data %}
    - bases: {{ index_data['bases'] }}
{% endif %}
{% if 'volatile' in index_data %}
    - volatile: {{ index_data['volatile'] }}
{% endif %}
{% endfor %}
{% endfor %}
