manage-linux-image:
  pkg.installed:
    - name: linux-image-{{ grains.osarch }}
    - refresh: False
    - version: latest

manage-linux-perf:
  pkg.installed:
    - name: linux-perf
    - refresh: False
    - version: latest
