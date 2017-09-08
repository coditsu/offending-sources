# frozen_string_literal: true

module Ruby
  # Updates given Ruby gem reference both in the DB and in the last generated file for a given day
  class Update < ApplicationOperation
    # Regexp to decide whether a given gem release is a prerelease or a regular one
    PRERELEASE_REGEXP = /[[:alpha:]]/

    step Macros::Params::Fetch(from: :ruby_gem)
    step :check_if_prerelease
    step :find_or_create_reference
    step :update_version_reference
    step :update_downloads_reference

    private

    # Checks if this is a prerelease (we handle those a bit differently)
    def check_if_prerelease(options, ruby_gem:, **)
      # @param _options [Trailblazer::Operation::Option]
      # @param ruby_gem [Hash] changed ruby gem details
      options['prerelease'] = (ruby_gem[:version] =~ PRERELEASE_REGEXP).nil?
      true
    end

    # Find or creates (if new gem added) a db reference of a given gem
    # @param options [Trailblazer::Operation::Option]
    # @param ruby_gem [Hash] changed ruby gem details
    def find_or_create_reference(options, ruby_gem, **)
      options['model'] = RubyGem.find_or_create_by!(name: ruby_gem[:name])
    end

    # Updates db references of a given ruby gem version
    # @param options [Trailblazer::Operation::Option]
    # @param model [Ruby::RubyGem] db gem reference
    # @param ruby_gem [Hash] changed ruby gem details
    # @param prerelease [Boolean] true if a given rubygem version is a prerelease
    def update_version_reference(options, model:, ruby_gem:, prerelease:, **)
      Version.where(rubygem_id: model.id).update_all(latest: false) unless prerelease

      options['version'] = Version.find_or_create_by!(
        number: ruby_gem[:version],
        rubygem_id: model.id,
        prerelease: prerelease,
        latest: !prerelease
      ).tap do |gem_version|
        built_at = gem_version.built_at || Time.zone.now
        licenses = ruby_gem[:licenses] || []
        gem_version.update(licenses: licenses, built_at: built_at)
        gem_version.save!
      end
    end

    # Updates db references of a given ruby gem downloads count
    # @param options [Trailblazer::Operation::Option]
    # @param model [Ruby::RubyGem] db gem reference
    # @param version [Ruby::Version] db gem version info reference
    # @param ruby_gem [Hash] changed ruby gem details
    def update_downloads_reference(options, model:, version:, ruby_gem:, **)
      options['gem_download'] = GemDownload.find_or_create_by(
        version_id: version.id,
        rubygem_id: model.id
      ).tap do |gem_download|
        gem_download.update!(count: ruby_gem[:version_downloads])
      end
    end
  end
end
