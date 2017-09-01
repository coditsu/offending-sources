# frozen_string_literal: true

module RubyGems
  class Update < ApplicationOperation
    step :extract_ruby_gem_details
    step :update_ruby_gems_database_reference
    step :update_current_day_file_reference

    private

    def extract_ruby_gem_details(options, params:, **)
      options[:ruby_gem] = params[:ruby_gem]
    end

    def update_ruby_gems_database_reference(_options, ruby_gem:, **)
      #RubyGem.connection.execute()
    end

    def update_current_day_file_reference(_options, ruby_gem:, **)
      true
    end
  end
end
