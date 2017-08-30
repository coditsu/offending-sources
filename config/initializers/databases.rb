# frozen_string_literal: true

RUBY_GEMS_DB = YAML.load_file(
  File.join(Rails.root, 'config', 'databases', 'rubygems.yml')
)[Rails.env.to_s]
