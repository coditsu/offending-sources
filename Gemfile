# frozen_string_literal: true

source 'https://rubygems.org'

gem 'airbrake'
gem 'dotenv-rails', require: 'dotenv/rails-now'
gem 'gems'
gem 'pg'
gem 'puma', git: 'git@github.com:puma/puma.git'
gem 'rails'
gem 'reform-rails'
gem 'trailblazer'
gem 'whenever'

%w[
  macros
].each do |gem_name|
  gem gem_name,
      git: "git@github.com:coditsu/#{gem_name.tr('_', '-')}.git",
      require: true,
      branch: :master
end

group :development, :test do
  gem 'byebug', platform: :mri
end

group :development do
  gem 'capistrano-coditsu',
      git: 'git@github.com:coditsu/capistrano-coditsu.git',
      branch: :master
end

group :test do
  gem 'database_cleaner'
  gem 'factory_bot_rails'
  gem 'rspec-rails'
  gem 'simplecov'
  gem 'support_engine', git: 'git@github.com:coditsu/support-engine.git'
end
