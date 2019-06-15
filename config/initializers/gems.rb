# frozen_string_literal: true

Gems.configure do |config|
  config.key = Rails.configuration.settings['ruby_gems']['api_key']
end
