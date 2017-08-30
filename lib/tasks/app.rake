# frozen_string_literal: true

namespace :app do
  desc 'Reloads RubyGems database dump and regenerates our source current files'
  task reload_all: :environment do
    RubyGems::ReloadAll.call
  end
end
