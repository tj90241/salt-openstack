manage-ifupdown:
  pkg.installed:
    - name: ifupdown
    - refresh: False
    - version: latest

{% if pillar['ifupdown']['managed'] %}
  file.managed:
    - name: /etc/network/interfaces
    - source: salt://ifupdown/interfaces.jinja
    - template: jinja
    - user: root
    - group: root
    - mode: 0644

manage-resolvconf:
  pkg.installed:
    - name: resolvconf
    - refresh: False
    - version: latest

  file.managed:
    - name: /etc/default/resolvconf
    - source: salt://resolvconf/default
    - user: root
    - group: root
    - mode: 0644

manage-interfaces:
  cmd.run:
    - name: "ifdown -a --exclude lo; {% if grains.get('virtual', 'virtual') == 'physical' %}systemctl restart openvswitch-switch; {% endif %}ifup -a; ifup --allow hotplug -a{% if grains.get('virtual', 'virtual') == 'physical' %}; ifup --allow ovs -a{% endif %}"
    - onchanges:
      - file: manage-ifupdown
      - file: manage-resolvconf

  module.run:
    - saltutil.refresh_grains:
    - onchanges:
      - file: manage-ifupdown
      - file: manage-resolvconf
{% endif %}
