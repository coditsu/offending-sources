# frozen_string_literal: true

Airbrake.configure do |config|
  config.performance_stats = false
  config.query_stats = false
  config.environment = Rails.env
  config.host        = Settings[:errbit][:host]
  config.project_id  = Settings[:errbit][:project_id]
  config.project_key = Settings[:errbit][:project_key]
  config.ignore_environments = %w[development test]
end
