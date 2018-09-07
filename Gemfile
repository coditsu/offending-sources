# frozen_string_literal: true

source 'https://rubygems.org'

gem 'dotenv-rails', require: 'dotenv/rails-now'
gem 'pg'
gem 'puma'
gem 'rails'
gem 'reform-rails'
gem 'settingslogic'
gem 'trailblazer'
gem 'whenever'

%w[
  macros
  karafka_coditsu
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
  gem 'rspec-rails'
  gem 'simplecov'
end
