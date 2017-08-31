# frozen_string_literal: true

ENV['RAILS_ENV'] ||= 'development'
ENV['KARAFKA_ENV'] = ENV['RAILS_ENV']
require ::File.expand_path('../config/environment', __FILE__)
Rails.application.eager_load!

# App class
class App < Karafka::App
  setup do |config|
    config.client_id = Settings.client_id
    config.redis = Settings.redis.symbolize_keys
    config.processing_backend = Karafka.env.development? ? :inline : :sidekiq
    config.kafka.seed_brokers = Settings.kafka.seed_brokers
    config.kafka.offset_commit_threshold = Settings.kafka.offset_commit_threshold
    config.monitor = KarafkaMonitor.instance
    config.batch_consuming = true
  end
end

App.boot!
