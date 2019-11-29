# frozen_string_literal: true

RUBY_GEMS_DB = YAML.load(
  ERB.new(
    File.read(
      Rails.root.join('config/databases/rubygems.yml')
    )
  ).result
)[Rails.env.to_s]
