{% set signing_pubkey_id = salt['cmd.shell']('gpg2 --list-keys --keyid-format=long "Apt Role Account" | awk -F "/" "/^sub/ {split(\\$2, a, \\" \\"); print a[1]}"', env=[{'GNUPGHOME': '/etc/reprepro'}]) %}

manage-reprepro:
  pkg.installed:
    - name: reprepro
    - refresh: False
    - version: latest

{# Expect script which grabs the GPG passphrase from the pillar for signing... #}
{# Invoke with: reprepro.exp -- args... #}
manage-reprepro-expect:
  file.managed:
    - name: /usr/local/bin/reprepro.exp
    - source: salt://reprepro/scripts/reprepro.exp
    - user: root
    - group: root
    - mode: 0755

manage-reprepro-distributions:
  file.managed:
    - name: /srv/repos/apt/salt-openstack/conf/distributions
    - source: salt://reprepro/distributions.jinja
    - template: jinja
    - user: root
    - group: root
    - mode: 0644
    - dir_mode: 0755
    - makedirs: True
    - context:
        signing_pubkey_id: {{ signing_pubkey_id }}

manage-reprepro-options:
  file.managed:
    - name: /srv/repos/apt/salt-openstack/conf/options
    - source: salt://reprepro/options
    - user: root
    - group: root
    - mode: 0644

manage-reprepro-pubkey:
  cmd.run:
    - name: gpg --batch --yes --armor --output /srv/repos/apt/Release.gpg --export-options export-minimal --export {{ signing_pubkey_id }}
    - env:
      - GNUPGHOME: /etc/reprepro

manage-reprepro-site:
  file.managed:
    - name: /etc/nginx/sites.d/reprepro.conf
    - source: salt://reprepro/sites/reprepro.conf.jinja
    - template: jinja
    - user: root
    - group: root
    - mode: 0644

  service.running:
    - name: nginx
    - enable: True
    - restart: True
    - watch:
      - file: manage-reprepro-site
