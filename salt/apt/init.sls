apt-manage-sources.list:
  file.managed:
    - name: /etc/apt/sources.list
    - source: salt://apt/sources.list.jinja
    - template: jinja
    - user: root
    - group: root

apt-package-database-update:
  module.wait:
    - name: pkg.refresh_db
    - watch:
      - file: /etc/apt/sources.list

{# As of apt 1.5.0+, HTTPS support has been moved into the apt package. #}
{% set apt_version = salt['pkg.version']('apt').split('.') %}

{% if apt_version[0] | int <= 1 and apt_version[1] | int < 5 %}
apt-provide-https-support:
  pkg.installed:
    - name: apt-transport-https
    - refresh: False
{% endif %}

apt-no-install-recommends:
  file.managed:
    - name: /etc/apt/apt.conf.d/99no-install-recommends
    - contents: |
        APT::Get::Install-Recommends "false";
        APT::Get::Install-Suggests "false";
    - user: root
    - group: root
    - mode: 0644

apt-system-update:
  pkg.uptodate:
    - refresh: True
    - dist_upgrade: True
