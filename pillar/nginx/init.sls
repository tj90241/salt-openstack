nginx:
  # Defines the number of worker processes.  The optimal value depends on many
  # factors including (but not limited to) the number of CPU cores, the number
  # of hard disk drives that store data, and load pattern.  When one is in
  # doubt, setting it to the number of available CPU cores would be a good
  # start (the value “auto” will try to autodetect it). 
  worker_processes: auto

  # Sets the maximum number of simultaneous connections that can be opened by a
  # worker process.  It should be kept in mind that this number includes all
  # connections (e.g. connections with proxied servers, among others), not only
  # connections with clients. Another consideration is that the actual number
  # of simultaneous connections cannot exceed the current limit on the maximum
  # number of open files, which can be changed by worker_rlimit_nofile.
  worker_connections: 768

  # If multi_accept is disabled, a worker process will accept one new
  # connection at a time.  Otherwise, a worker process will accept all
  # new connections at a time. 
  multi_accept: True
