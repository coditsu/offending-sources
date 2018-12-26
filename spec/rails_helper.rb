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
].each { |lib| require lib }
