# frozen_string_literal: true

%w[
  scm/git
  setup
  deploy
  bundler
  rvm
  console
  puma
  sidekiq
].each { |lib| require "capistrano/#{lib}" }

install_plugin Capistrano::SCM::Git
install_plugin Capistrano::Puma
install_plugin Capistrano::Karafka
