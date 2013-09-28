require 'mina/bundler'
require 'mina/git'
require 'mina/rsync'
# 1. mina setup
# 2. mina deploy
# 3. mina setup_init

# require 'mina/rbenv'  # for rbenv support. (http://rbenv.org)
set :domain, 'prod-puppet1-ep.tops.gdi'
set :deploy_to, '/opt/smart-proxy'
set :current, deploy_to + '/current'
set :shared, deploy_to + '/shared'
set :repository, 'git@github.com:teaforthecat/smart-proxy.git'
set :branch, 'master'
set :user, 'puppet-deployer'
set :rsync_options, %w[-q --recursive --executability --delete --delete-excluded --exclude .git*]
set :ssh_options, '-q'

set :bundle_options, '--binstubs --path .bundle --deployment --without development:bmc:krb5:test '
set :bundle_path, '.bundle'

# root operations:
# mkdir -p /opt/smart-proxy && chown -R puppet-deployer:puppet-deployer /opt/smart-proxy
# add to sudoers: cp /opt/smart-proxy/current/config/smart-proxy.init.d /etc/init.d/smart-proxy
task :setup do
  queue! %[mkdir -p "#{deploy_to}"]
  queue! %[mkdir -p "#{deploy_to}/shared/deploy"]
  queue! %[mkdir -p "#{deploy_to}/shared/bundle"]
  queue! %[mkdir -p "#{deploy_to}/shared/log"]
  queue! %[mkdir -p "#{deploy_to}/shared/pids"]
  queue! %[mkdir -p "#{deploy_to}/tmp/deploy"]
end

task :setup_init do
  queue! "sudo cp -p #{deploy_to}/current/config/smart-proxy.init.d /etc/init.d/smart-proxy"
end

task :deploy do
  deploy do
    invoke 'rsync:deploy'
  end
  queue "ln -sf #{shared}/bundle #{current}/.bundle "
  queue "ln -sf #{shared}/log #{current}/log "
  queue "cd #{current} && bundle install --binstubs --path .bundle --deployment --without development:test"
  to :launch do
    queue "sudo service smart-proxy restart"
  end
end
