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

manage-reprepro-expect-sudoers:
  file.managed:
    - name: /etc/sudoers.d/reprepro
    - source: salt://reprepro/sudoers.jinja
    - template: jinja
    - user: root
    - group: root
    - mode: 0640

manage-reprepro-distributions:
  file.managed:
    - name: /var/lib/reprepro/repos/salt-openstack/conf/distributions
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
    - name: /var/lib/reprepro/repos/salt-openstack/conf/options
    - source: salt://reprepro/options
    - user: root
    - group: root
    - mode: 0644

manage-reprepro-pubkey:
  cmd.run:
    - name: gpg --batch --yes --armor --output /var/lib/reprepro/repos/Release.gpg --export-options export-minimal --export {{ signing_pubkey_id }}
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

manage-jenkins-publish:
  file.managed:
    - name: /usr/local/bin/jenkins-publish.sh
    - source: salt://reprepro/scripts/jenkins-publish.sh.jinja
    - template: jinja
    - user: root
    - group: root
    - mode: 0755

manage-consul-apt:
  file.managed:
    - name: /etc/consul.d/apt.json
    - source: salt://reprepro/consul.json.jinja
    - template: jinja
    - user: consul
    - group: consul
    - mode: 0640

  service.running:
    - name: consul
    - restart: True
    - watch:
      - file: manage-consul-apt
