#debian-installer:
#  macs:
#    'aa:bb:cc:dd:ee:ff':
#      hostname: host1
#      domain: example.com
#      preseed_dir_url: tftp://x.x.x.x/preseed
#      template: whitebox-9000
#
#    '00:07:32:4c:13:52':
#      hostname: host2
#      domain: example.com
#      preseed_dir_url: tftp://x.x.x.x/preseed
#      template: whitebox-9000
#
#  templates:
#    whitebox-9000:
#      cmdline: console=tty0 console=ttyS1,115200n81 quiet
#      filename: whitebox-9000.conf.jinja

