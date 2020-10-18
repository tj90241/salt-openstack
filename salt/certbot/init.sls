manage-certbot:
  pkg.installed:
    - name: certbot
    - refresh: False
    - version: latest

  {# We configure cert autorenewal via Salt schedules. #}
  file.absent:
    - name: /etc/cron.d/certbot

  service.dead:
    - name: certbot.timer
    - enable: False
