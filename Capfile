# frozen_string_literal: true

%w[
  coditsu
  scm/git
  setup
  deploy
  console
  puma
  karafka
].each { |lib| require "capistrano/#{lib}" }

install_plugin Capistrano::Coditsu
install_plugin Capistrano::SCM::Git
install_plugin Capistrano::Puma
install_plugin Capistrano::Karafka
