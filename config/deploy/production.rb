# frozen_string_literal: true

server 'coditsu-production-frontend',
  roles: %w[web],
  user: 'deploy'

server 'coditsu-production-main',
  roles: %w[app db karafka],
  user: 'deploy'

set :ssh_options,
  port: 2222,
  forward_agent: true

set :stage, :production
set :environment, 'production'
set :rails_env, fetch(:environment)

set :tmp_dir, '/home/deploy/.tmp'
set :deploy_to, "/home/deploy/coditsu/#{fetch(:application)}"

set :karafka_env, fetch(:environment)
set :karafka_pid, "#{shared_path}/tmp/pids/karafka.pid"

set :puma_conf,  "#{shared_path}/config/puma.rb"
set :puma_pid,   "#{shared_path}/tmp/pids/puma"
set :puma_state, "#{shared_path}/tmp/sockets/pumastate"

set :rvm_custom_path, '/usr/local/rvm'
set :rvm_ruby_version, "2.4.1@#{fetch(:application)}"

set :branch, ENV['REVISION'] || ENV['BRANCH_NAME'] || 'master'
set :domain, 'offending-sources.coditsu.io'
