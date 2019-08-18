# frozen_string_literal: true

require_relative 'boot'

%w[
  rails
  active_record
  action_controller/railtie
].each { |lib| require lib }

# Require the gems listed in Gemfile, including any gems
# you've limited to :test, :development, or :production.
Bundler.require(*Rails.groups)

%w[
  fileutils
  csv
].each(&method(:require))

# OffendingSources module
module OffendingSources
  # OffendingSources app
  class Application < Rails::Application
    config.api_only = true
    config.load_defaults 5.1
    config.settings = config_for(:settings)
    config.hosts << Rails.configuration.settings[:host]
  end
end

# App settings alias
Settings = Rails.configuration.settings

%w[
  lib/errors.rb
].each do |path|
  Dir[Rails.root.join(path)].each do |base|
    require base
  end
end
