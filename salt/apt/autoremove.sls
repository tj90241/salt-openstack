apt-autoremove-purge:
  module.run:
    - pkg.autoremove:
      - purge: True
