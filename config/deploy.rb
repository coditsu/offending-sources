# frozen_string_literal: true

set :application,   'offending-sources'
set :repo_url,      "git@bitbucket.org:coditsu/#{fetch(:application)}.git"
set :keep_releases, 5
set :log_level,     :debug
set :copy_exclude,  %w[.svn .DS_Store cache]
