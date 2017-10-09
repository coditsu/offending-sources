# frozen_string_literal: true

module Ruby
  # Reloads source files
  class ReloadSources < ApplicationOperation
    step lambda { |_options, **|
      Ruby::GemsLicenser::Reload.call({})
      Ruby::GemsTyposquattingDetector::Reload.call({})
      Ruby::OutdatedGems::Reload.call({})
      Ruby::AbandonedGems::Reload.call({})
    }
  end
end
