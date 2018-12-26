# frozen_string_literal: true

%w[
  scm/git
  setup
  deploy
  console
  puma
].each { |lib| require "capistrano/#{lib}" }

require 'whenever/capistrano'

install_plugin Capistrano::Coditsu
install_plugin Capistrano::SCM::Git
install_plugin Capistrano::Puma

Dir.glob('lib/capistrano/tasks/*.cap').each { |r| import r }
