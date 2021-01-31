isc-dhcp-server:
  authoritative: True

  defaults:
    default_lease_time: 600
    deny_client_updates: True
    deny_unknown_clients: True
    max_lease_time: 7200
    pxe_filenames:
      bios: syslinux/bios/pxelinux.0
      efi32: syslinux/efi32/syslinux.efi
      efi64: syslinux/efi64/syslinux.efi
