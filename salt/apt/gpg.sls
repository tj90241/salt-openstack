manage-apt-keyring:
  file.managed:
    - name: /etc/gpg/pubring.kbx
    - contents_pillar: gpg:pubring.kbx
    - user: root
    - group: root
    - mode: 0640
    - dir_mode: 0750
    - makedirs: True

manage-apt-keyring-tilde:
  file.managed:
    - name: /etc/gpg/pubring.kbx~
    - contents_pillar: gpg:pubring.kbx~
    - user: root
    - group: root
    - mode: 0640

{% for private_key in pillar['gpg'].get('private-keys-v1.d', []).keys() %}
manage-apt-private-key-{{ private_key }}:
  file.managed:
    - name: /etc/gpg/private-keys-v1.d/{{ private_key }}
    - contents_pillar: gpg:private-keys-v1.d:{{ private_key }}
    - user: root
    - group: root
    - mode: 0640
    - dir_mode: 0750
    - makedirs: True
{% endfor %}

{% for revocation in pillar['gpg'].get('openpgp-revocs.d', []).keys() %}
manage-apt-revocations-{{ revocation }}:
  file.managed:
    - name: /etc/gpg/openpgp-revocs.d/{{ revocation }}
    - contents_pillar: gpg:openpgp-revocs.d:{{ revocation }}
    - user: root
    - group: root
    - mode: 0640
    - dir_mode: 0750
    - makedirs: True
{% endfor %}
