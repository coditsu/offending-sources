# frozen_string_literal: true

module Ruby
  # Updates given Ruby gem reference both in the DB and in the last generated file for a given day
  class UpdateDb < ApplicationOperation
    # Regexp to decide whether a given gem release is a prerelease or a regular one
    PRERELEASE_REGEXP = /[[:alpha:]]/

    step :check_if_prerelease
    step :find_or_create_reference
    step :update_version_reference
    step :update_downloads_reference
    step :resolve_latest

    private

    # Checks if this is a prerelease (we handle those a bit differently)
    def check_if_prerelease(ctx, params:, **)
      # @param _ctx [Trailblazer::Skill]
      # @param params [Hash] changed ruby gem details
      ctx['prerelease'] = !(params[:version] =~ PRERELEASE_REGEXP).nil?
      true
    end

    # Find or creates (if new gem added) a db reference of a given gem
    # @param ctx [Trailblazer::Skill]
    # @param params [Hash] changed ruby gem details
    def find_or_create_reference(ctx, params:, **)
      ctx['model'] = RubyGem.find_or_create_by!(name: params[:name])
    end

    # Updates db references of a given ruby gem version
    # @param ctx [Trailblazer::Skill]
    # @param model [Ruby::RubyGem] db gem reference
    # @param params [Hash] changed ruby gem details
    # @param prerelease [Boolean] true if a given rubygem version is a prerelease
    def update_version_reference(ctx, model:, params:, prerelease:, **)
      ctx['version'] = Version.find_or_create_by!(
        number: params[:version],
        rubygem_id: model.id,
        prerelease: prerelease,
        latest: false # We mark new not as a latest as we will resolve latest later
      ).tap do |gem_version|
        built_at = gem_version.built_at || Time.zone.now
        licenses = params[:licenses] || []
        gem_version.update!(licenses: licenses, built_at: built_at)
      end
    end

    # Updates db references of a given ruby gem downloads count
    # @param ctx [Trailblazer::Skill]
    # @param model [Ruby::RubyGem] db gem reference
    # @param version [Ruby::Version] db gem version info reference
    # @param params [Hash] changed ruby gem details
    def update_downloads_reference(ctx, model:, version:, params:, **)
      ctx['gem_download'] = GemDownload.find_or_create_by!(
        version_id: version.id,
        rubygem_id: model.id
      ).tap do |gem_download|
        gem_download.update!(count: params[:version_downloads])
      end
    end

    # Figures out the most recent, top, non prerelease version of a given gem version and
    # marks it as latest in the DB
    # @param _ctx [Trailblazer::Skill]
    # @param model [Ruby::RubyGem] db gem reference
    # @param version [Ruby::Version] db gem version info reference
    def resolve_latest(_ctx, model:, version:, **)
      # If it is a prerelease, we ignore as prereleases are never marked as latest
      return true if version.prerelease
      latest = Version.find_by(rubygem_id: model.id, latest: true)
      return true if !latest.nil? && latest.comparator >= version.comparator
      Version.where(rubygem_id: model.id).update_all(latest: false)
      version.update!(latest: true)
    end
  end
end
