# frozen_string_literal: true

# Namespace for all the things related to Ruby and Rubygems
module Ruby
  # Downloads new Rubygems database
  class ReloadDb < ApplicationOperation
    step :prepare_env_variables
    step :fetch_and_reload_rubygems_db

    private

    # Prepares all the env variables that we need to have in order to run sh DB update script
    # @param options [Trailblazer::Operation::Option]
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
        "DB_NAME=#{database}",
        "RAILS_ROOT=#{Rails.root}"
      ]
    end

    # Runs the DB reload script with proper envs
    # @param _options [Trailblazer::Operation::Option]
    # @param env_variables [Hash] envs that we need to pass to reload script
    def fetch_and_reload_rubygems_db(_options, env_variables:, **)
      cmd = Rails.root.join('bin', 'rubygems', 'reload.sh download')
      system(env_variables.join(' ') + ' ' + cmd.to_s)
    end
  end
end
