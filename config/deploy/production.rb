# frozen_string_literal: true

server 'sources.prod.coditsu.io',
       roles: %w[web app db],
       user: 'deploy'

set :ssh_options, forward_agent: true

set :stage, :production
set :environment, 'production'
set :rails_env, fetch(:environment)
set :rbenv_type, :user
set :rbenv_ruby, '2.6.3'
set :settings_path, "config/deploy/#{fetch(:stage)}"

set :tmp_dir, '/home/deploy/.tmp'
set :deploy_to, "/home/deploy/coditsu/#{fetch(:application)}"

set :puma_conf,  "#{shared_path}/config/puma.rb"
set :puma_pid,   "#{shared_path}/tmp/pids/puma"
set :puma_state, "#{shared_path}/tmp/sockets/pumastate"

set :branch, 'master'
set :domain, 'sources.prod.coditsu.io'

set :whenever_roles, %i[app db web]
