# frozen_string_literal: true

module RubyGems
  # Reloads source files
  class ReloadSources < ApplicationOperation
    step lambda { |_options, **|
      RubyGems::GemsLicenser::Reload.call({})
      RubyGems::GemsTyposquattingDetector::Reload.call({})
      RubyGems::OutdatedGems::Reload.call({})
    }
  end
end
