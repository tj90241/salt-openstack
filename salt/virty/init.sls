manage-virty:
  file.managed:
    - name: /usr/local/sbin/virty
    - source: salt://virty/virty
    - user: root
    - group: root
    - mode: 0755

{% for vm_name, vm_data in pillar.get('virty', {}).get('vms', {}).items() %}
{% set vm_name_filtered = vm_name.lower().replace(' ', '_') %}
manage-virty-vm-{{ vm_name_filtered }}:
  file.managed:
    - name: /etc/systemd/system/{{ vm_name_filtered }}-vm.service
    - source: salt://virty/virty-vm.service.jinja
    - template: jinja
    - user: root
    - group: root
    - mode: 0644
    - context:
        vm_name: {{ vm_name }}
        vm_name_filtered: {{ vm_name_filtered }}
        vm_cores: {{ vm_data['cores'] }}
        vm_cpu_affinity: {{ vm_data.get('cpu_affinity', False) }}
        vm_emu_affinity: {{ vm_data.get('emu_affinity', False) }}
        vm_cpu_pin: {{ vm_data.get('cpu_pin', False) }}
        vm_numanodes: {{ vm_data.get('numanodes', False) }}
        vm_ram: {{ vm_data['ram'] }} 
{% if 'blockdev' in vm_data %}
{%- set vm_storage_data = salt['cmd.run']('lsblk -Jb ' + vm_data['blockdev']) | load_json %}
        vm_storage: {{ vm_storage_data['blockdevices'][0]['size'] | int // 1048576 }}
        vm_storage_pool: {{ vm_data['blockdev'] }}:block
        vm_skip_pool_creation: True
{% else %}
        vm_storage: {{ vm_data['storage'] }}
        vm_storage_pool: {{ vm_data.get('storage_pool', 'default') }}
        vm_skip_pool_creation: False
{% endif %}
        vm_storage_pool_dir: {{ vm_data.get('storage_pool_dir', '/var/lib/libvirt/images') }}
        vm_bridge_or_nic: {{ vm_data['bridge_or_nic'] }}
        vm_nic_vlan: {{ vm_data.get('vlan', False) }}
        vm_nic_rom_bar: {{ vm_data.get('rom_bar', False) }}
        vm_mac: {{ vm_data['mac'] }}

  module.run:
    - service.systemctl_reload:
    - onchanges:
      - file: manage-virty-vm-{{ vm_name_filtered }}

  service.enabled:
    - name: {{ vm_name_filtered }}-vm.service
{% endfor %}
