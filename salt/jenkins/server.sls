include:
  - jenkins.pkgrepo

manage-jenkins-override:
  file.managed:
    - name: /etc/systemd/system/jenkins.service.d/override.conf
    - source: salt://jenkins/override.conf.jinja
    - template: jinja
    - user: root
    - group: root
    - mode: 0600
    - dir_mode: 0755
    - makedirs: True

  module.run:
    - service.systemctl_reload:
    - onchanges:
      - file: manage-jenkins-override

manage-jenkins:
  pkg.installed:
    - name: jenkins
    - refresh: False
    - version: latest

  file.managed:
    - name: /etc/default/jenkins
    - source: salt://jenkins/default.jinja
    - template: jinja
    - user: root
    - group: root
    - mode: 0644

  service.running:
    - name: jenkins
    - enable: True
    - restart: True
    - watch:
      - pkg: jenkins
      - file: manage-jenkins
      - cmd: manage-jenkins-jks

manage-jenkins-jks:
  file.managed:
    - name: /var/lib/jenkins/ssl.pem
    - contents_pillar:
      - ssl:privkey.pem
      - ssl:fullchain.pem
    - contents_newline: True
    - user: jenkins
    - group: jenkins
    - mode: 0600

  cmd.run:
    - name: |
        openssl pkcs12 -in /var/lib/jenkins/ssl.pem -export -out /var/lib/jenkins/cert.p12 -passout "pass:${JKS_PASSWORD}" &&
        keytool -importkeystore -srckeystore /var/lib/jenkins/cert.p12 -srcstoretype pkcs12 -destkeystore /var/lib/jenkins/cert.jks -srcstorepass "${JKS_PASSWORD}" -storepass "${JKS_PASSWORD}" -noprompt &&
        chmod 0600 /var/lib/jenkins/cert.jks
    - env:
        JKS_PASSWORD: '{{ pillar['jenkins']['controller']['jks']['password'] }}'
    - runas: jenkins
    - onchanges:
      - file: manage-jenkins-jks

manage-consul-jenkins:
  file.managed:
    - name: /etc/consul.d/jenkins.json
    - source: salt://jenkins/consul.json.jinja
    - template: jinja
    - user: consul
    - group: consul
    - mode: 0640

  service.running:
    - name: consul
    - restart: True
    - watch:
      - file: manage-consul-jenkins

manage-jcasc-config:
  file.recurse:
    - name: /var/lib/jenkins/jcasc
    - source: salt://jenkins/jcasc.jinja
    - template: jinja
    - user: jenkins
    - group: jenkins
    - dir_mode: 0750
    - file_mode: 0640
