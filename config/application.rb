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

require 'fileutils'

# OffendingSources module
module OffendingSources
  # OffendingSources app
  class Application < Rails::Application
    config.api_only = true
    config.load_defaults 5.1
  end
end

%w[
  lib/errors.rb
].each do |path|
  Dir[Rails.root.join(path)].each do |base|
    require base
  end
end
