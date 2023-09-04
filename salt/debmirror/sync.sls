sync-archive-mirror:
  cmd.run:
    - name: >
        debmirror -h mirrors.lug.mtu.edu -r debian -d bookworm,bookworm-updates
        --keyring /usr/share/keyrings/debian-archive-bookworm-automatic.gpg
        {{ salt['file.join'](pillar['debmirror']['location'], 'debian') }}
    - runas: root

sync-security-mirror:
  cmd.run:
    - name: >
        debmirror -h rsync.security.debian.org -r debian-security -d bookworm-security
        --keyring /usr/share/keyrings/debian-archive-bookworm-security-automatic.gpg
        {{ salt['file.join'](pillar['debmirror']['location'], 'debian-security') }}
    - runas: root
