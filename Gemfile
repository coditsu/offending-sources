# frozen_string_literal: true

source 'https://rubygems.org'

gem 'airbrake'
gem 'karafka', git: 'https://github.com/karafka/karafka'
gem 'macros', git: 'git@bitbucket.org:coditsu/macros.git', require: true, branch: :master
gem 'pg'
gem 'puma'
gem 'rails'
gem 'reform-rails'
gem 'settingslogic'
gem 'trailblazer'

group :development, :test do
  gem 'byebug', platform: :mri
end

group :development do
  gem 'bcrypt_pbkdf'
  gem 'capistrano-bundler', require: false
  gem 'capistrano-rails', require: false
  gem 'capistrano-rvm', require: false
  gem 'capistrano3-puma', require: false
  gem 'net-ssh'
  gem 'rbnacl', '< 5.0'
  gem 'rbnacl-libsodium'
end

group :test do
  gem 'rspec-rails'
  gem 'shoulda'
  gem 'simplecov'
end
