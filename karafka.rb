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
    config.batch_fetching = true
    config.params_base_class = HashWithIndifferentAccess
    config.parser = KarafkaCoditsu::Parser
  end

  Karafka.monitor.subscribe(Karafka::Instrumentation::Listener)
  Karafka.monitor.subscribe(KarafkaCoditsu::AirbrakeListener)

  consumer_groups.draw do
    topic :webhooks_ruby_gems_received do
      consumer Ruby::UpdateDbConsumer
    end
  end
end

App.boot!
