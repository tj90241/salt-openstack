devpi:
  server:
    role: standalone

    host: localhost
    port: 3141
    threads: 50
    
    serverdir: /var/lib/devpi/data
    storage: sqlite
    keyfs_cache_size: 1000
