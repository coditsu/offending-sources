# frozen_string_literal: true

%w[
  scm/git
  setup
  deploy
  console
  coditsu
  puma
  karafka
].each { |lib| require "capistrano/#{lib}" }

require 'whenever/capistrano'

install_plugin Capistrano::Coditsu
install_plugin Capistrano::SCM::Git
install_plugin Capistrano::Puma
install_plugin Capistrano::Karafka

Dir.glob('lib/capistrano/tasks/*.cap').each { |r| import r }
