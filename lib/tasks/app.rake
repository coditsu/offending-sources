# frozen_string_literal: true

namespace :app do
  desc 'Reloads RubyGems database dump and regenerates our source current files'
  task reload_db: :environment do
    RubyGems::ReloadDb.call
  end

  desc 'Reloads only the sources files, without reloading the whole database'
  task reload_sources: :environment do
    RubyGems::GemsLicenser::Reload.call({})
    RubyGems::GemsTyposquattingDetector::Reload.call({})
    RubyGems::OutdatedGems::Reload.call({})
  end
end
