# frozen_string_literal: true

RUBY_GEMS_DB = YAML.load_file(
  Rails.root.join('config', 'databases', 'rubygems.yml')
)[Rails.env.to_s]
