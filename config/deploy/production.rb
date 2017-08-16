# frozen_string_literal: true

server 'coditsu-production-frontend',
  roles: %w[web processor_high],
  user: 'deploy'

set :ssh_options,
  port: 2222,
  forward_agent: true

set :stage, :production
set :environment, 'production'
set :rails_env, fetch(:environment)

set :tmp_dir, '/home/deploy/.tmp'
set :deploy_to, "/home/deploy/coditsu/#{fetch(:application)}"

set :branch, ENV['REVISION'] || ENV['BRANCH_NAME'] || 'master'
set :domain, "#{fetch(:application)}.coditsu.it"
