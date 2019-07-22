# frozen_string_literal: true

# This file is copied to spec/ when you run 'rails generate rspec:install'
ENV['RAILS_ENV'] ||= 'test'
ENV['KARAFKA_ENV'] ||= 'test'
require 'spec_helper'

require File.expand_path('../config/environment', __dir__)

%w[
  rails
  active_record
  action_controller/railtie
  rspec/rails
].each { |lib| require lib }

RSpec.configure do |config|
  config.infer_spec_type_from_file_location!
end
