# frozen_string_literal: true

Airbrake.configure do |config|
  config.performance_stats = false
  config.environment = Rails.env
  config.host        = Rails.configuration.settings['errbit']['host']
  config.project_id  = Rails.configuration.settings['errbit']['project_id']
  config.project_key = Rails.configuration.settings['errbit']['project_key']
  config.ignore_environments = %w[development test]
end
