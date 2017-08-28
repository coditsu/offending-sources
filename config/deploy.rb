# frozen_string_literal: true

set :application,   'webhooks-manager'
set :repo_url,      "git@bitbucket.org:coditsu/#{fetch(:application)}.git"
set :keep_releases, 10
set :log_level,     :debug
set :copy_exclude,  %w[.svn .DS_Store cache]
set :puma_role,     :web

set :linked_files, %w[
  config/secrets.yml
  config/database.yml
  config/settings.yml
  config/puma.rb
  config/sidekiq.yml
]

set :linked_dirs, %w[
  log
  tmp
  db/sources
  .bundle
  bundle
]

after 'deploy:finished', 'puma:start'
