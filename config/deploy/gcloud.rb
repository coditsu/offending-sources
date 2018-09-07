# frozen_string_literal: true

server 'orchestration-vm1.prod.coditsu.it',
       roles: %w[web app db karafka],
       user: 'deploy'

set :ssh_options, forward_agent: true

set :stage, :production
set :environment, 'production'
set :rails_env, fetch(:environment)
set :rbenv_type, :user
set :rbenv_ruby, '2.5.1'
set :settings_path, "config/deploy/#{fetch(:stage)}"

set :tmp_dir, '/home/deploy/.tmp'
set :deploy_to, "/home/deploy/coditsu/#{fetch(:application)}"

set :karafka_env, fetch(:environment)
set :karafka_pid, "#{shared_path}/tmp/pids/karafka.pid"

set :puma_conf,  "#{shared_path}/config/puma.rb"
set :puma_pid,   "#{shared_path}/tmp/pids/puma"
set :puma_state, "#{shared_path}/tmp/sockets/pumastate"

set :branch, ENV['REVISION'] || ENV['BRANCH_NAME'] || 'master'
set :domain, 'orchestration-vm1.prod.coditsu.it'

set :whenever_roles, %i[app db web]
