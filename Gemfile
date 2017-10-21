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
gem 'whenever'

group :development, :test do
  gem 'byebug', platform: :mri
end

group :development do
  gem 'capistrano-coditsu', 
    git: 'git@bitbucket.org:coditsu/capistrano-coditsu.git', 
    branch: :master
end

group :test do
  gem 'rspec-rails'
  gem 'shoulda'
  gem 'simplecov'
end
