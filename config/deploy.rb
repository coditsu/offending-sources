# frozen_string_literal: true

set :application,   'offending-sources'
set :repo_url,      "git@github.com:coditsu/#{fetch(:application)}.git"
set :keep_releases, 10
set :log_level,     :debug
set :copy_exclude,  %w[.svn .DS_Store cache]
set :puma_role,     :web

set :linked_files, %w[
  .env
  config/secrets.yml
  config/databases/rubygems.yml
  config/settings.yml
  config/puma.rb
]

set :linked_dirs, %w[
  log
  tmp
  db/sources
  .bundle
  bundle
  public
]

set :created_dirs, %w[
  tmp/pids
  tmp/sockets
]

after 'deploy:finished', 'puma:start'
