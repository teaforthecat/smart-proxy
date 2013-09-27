# define paths and filenames
port      = 8443
deploy_to = "/opt/smart-proxy"
app_root  = "#{deploy_to}/current"
pid_file  = "#{deploy_to}/shared/unicorn.pid"
log_file  = "#{app_root}/log/unicorn.log"
err_log   = "#{app_root}/log/unicorn_error.log"
old_pid   = pid_file + '.oldbin'

timeout 30
worker_processes 1 # increase or decrease
listen port, :backlog => 1024

pid pid_file
stderr_path err_log
stdout_path log_file
working_directory app_root


before_fork do |server, worker|
  # zero downtime deploy magic:
  # if unicorn is already running, ask it to start a new process and quit.
  if File.exists?(old_pid) && server.pid != old_pid
    begin
      Process.kill("QUIT", File.read(old_pid).to_i)
    rescue Errno::ENOENT, Errno::ESRCH
      # someone else did our job for us
    end
  end
end
