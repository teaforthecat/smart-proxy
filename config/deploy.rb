require 'mina/bundler'
require 'mina/git'
require 'mina/rsync'
# 1. mina setup
# 2. mina deploy
# 3. mina setup_init

# require 'mina/rbenv'  # for rbenv support. (http://rbenv.org)
set :domain, 'prod-puppet1-ep.tops.gdi'
set :deploy_to, '/opt/smart-proxy'
set :repository, 'git@github.com:teaforthecat/smart-proxy.git'
set :branch, 'master'
set :user, 'puppet-deployer'
set :rsync_options, %w[--recursive --delete --delete-excluded --exclude .git*]
set :ssh_options, '-q'

set :bundle_options, '--binstubs --path .bundle --deployment --without development,bmc,krb5,test '

# root operations:
# mkdir -p /opt/smart-proxy && chown -R puppet-deployer:puppet-deployer /opt/smart-proxy
# add to sudoers: cp /opt/smart-proxy/current/config/smart-proxy.init.d /etc/init.d/smart-proxy
task :setup do
  queue! %[mkdir -p "#{deploy_to}"]
  queue! %[mkdir -p "#{deploy_to}/shared/deploy"]
  queue! %[mkdir -p "#{deploy_to}/tmp/deploy"]
end

task :setup_init do
  queue! %[sudo cp "#{deploy_to}"/current/config/smart-proxy.init.d /etc/init.d/smart-proxy ]
  queue! %[sudo ln -s /etc/init.d/smart-proxy /etc/rc.d/init.d/smart-proxy ]
end

task :deploy do
  deploy do
    invoke 'rsync:deploy'
    # to :launch do
    #   queue "touch #{deploy_to}/tmp/restart.txt"
    # end
  end
end
