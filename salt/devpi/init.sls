include:
  - python3.pip
  - python3.pkg-resources
  - python3.setuptools
  - python3.wheel
  - virtualenv

manage-devpi-user:
  group.present:
    - name: {{ pillar['devpi']['group'] }}
    - system: True

  user.present:
    - name: {{ pillar['devpi']['user'] }}
    - groups:
      - {{ pillar['devpi']['group'] }}
    - createhome: False
    - home: /var/lib/devpi
    - password: '*'
    - shell: /usr/sbin/nologin
    - system: True
    - fullname: PyPI Server Role Account

  file.directory:
    - name: /var/lib/{{ pillar['devpi']['user'] }}
    - user: {{ pillar['devpi']['user'] }}
    - group: {{ pillar['devpi']['group'] }}
    - mode: 0750

manage-devpi-virtualenv:
  file.directory:
    - name: {{ salt['file.join'](pillar['devpi']['virtualenv']) }}
    - user: {{ pillar['devpi']['user'] }}
    - group: {{ pillar['devpi']['group'] }}
    - mode: 0755

  cmd.run:
    - name: /usr/bin/virtualenv -p {{ pillar['devpi']['python3'] }} --verbose --clear --never-download --system-site-packages {{ pillar['devpi']['virtualenv'] }}
    - runas: {{ pillar['devpi']['user'] }}
    - onchanges:
      - file: manage-devpi-virtualenv
