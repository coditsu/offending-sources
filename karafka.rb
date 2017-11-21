# frozen_string_literal: true

ENV['RAILS_ENV'] ||= 'development'
ENV['KARAFKA_ENV'] = ENV['RAILS_ENV']
require ::File.expand_path('../config/environment', __FILE__)
Rails.application.eager_load!

# App class
class App < Karafka::App
  setup do |config|
    config.client_id = Settings.client_id
    config.kafka.seed_brokers = Settings.kafka.seed_brokers
    config.kafka.offset_commit_threshold = Settings.kafka.offset_commit_threshold
    config.monitor = KarafkaCoditsu::Monitor.instance
    config.batch_fetching = true
  end

  consumer_groups.draw do
    topic :webhooks_ruby_gems_received do
      controller Ruby::UpdateDbController
    end
  end
end

App.boot!
