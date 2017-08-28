# frozen_string_literal: true

module RubyGems
  class ReloadAll < ApplicationOperation
    step :prepare_env_variables
    step :fetch_and_reload_rubygems_db
    step :reload_sources

    private

    def prepare_env_variables(options, **)
      username = RUBY_GEMS_DB['username']
      password = RUBY_GEMS_DB['password']
      database = RUBY_GEMS_DB['database']
      host = RUBY_GEMS_DB['host']
      port = RUBY_GEMS_DB['port']

      options['env_variables'] = [
        "DB_USERNAME=#{username}",
        "DB_PASSWORD='#{password}'",
        "DB_HOST=#{host}",
        "DB_PORT=#{port}",
        "DB_NAME=#{database}"
      ]
    end

    def fetch_and_reload_rubygems_db(options, env_variables:, **)
      cmd = File.join(Rails.root, 'bin', 'rubygems', 'reload.sh download')

      system(env_variables.join(' ') + ' ' +cmd)
    end

    def reload_sources(options, **)
      RubyGems::GemsLicenser::Reload.call({})
      RubyGems::GemsTyposquattingDetector::Reload.call({})
      RubyGems::OutdatedGems::Reload.call({})
    end
  end
end
