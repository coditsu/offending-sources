# frozen_string_literal: true

namespace :app do
  desc 'Reloads Ruby database dump and regenerates our source current files'
  task reload_db: :environment do
    Ruby::ReloadDb.call
  end

  desc 'Reloads only the sources files, without reloading the whole database'
  task reload_sources: :environment do
    Ruby::GemsLicenser::Reload.call({})
    Ruby::GemsTyposquattingDetector::Reload.call({})
    Ruby::OutdatedGems::Reload.call({})
  end
end
