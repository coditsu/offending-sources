# frozen_string_literal: true

module RubyGems
  # Updates given Ruby gem reference both in the DB and in the last generated file for a given day
  class Update < ApplicationOperation
    step Macros::Params::Fetch(from: :ruby_gem)
    step :find_or_create_reference
    step :check_if_prerelease
    step :update_ruby_gems_database_reference
    step :update_current_day_file_reference

    private

    def find_or_create_reference(options, ruby_gem, **)
      options['model'] = RubyGem.find_or_create_by(name: ruby_gem[:name])
    end

    def check_if_prerelease(options, ruby_gem:, **)
      options['prerelease'] = !(ruby_gem[:version] !~ /[[:alpha:]]/)
      true
    end

    def update_ruby_gems_database_reference(options, ruby_gem:, model:, prerelease:, **)
      Version.where(rubygem_id: model.id).update_all(latest: false) unless prerelease

      options['version'] = Version.find_or_create_by(
        number: ruby_gem[:version],
        rubygem_id: model.id,
        prerelease: prerelease,
        latest: !prerelease
      )

      options['version'].update(
        licenses: ruby_gem[:licenses] || []
      )

      options['gem_download'] = GemDownload.find_or_create_by(
        version_id: options['version'].id,
        rubygem_id: model.id
      )

      options['gem_download'].update(count: ruby_gem[:version_downloads])
      options['version'].update(built_at: Time.zone.now) unless options['version'].built_at
    end

    def update_current_day_file_reference(_options, ruby_gem:, **)
      true
    end
  end
end
