# frozen_string_literal: true

module Ruby
  # Namespace for things related to tracking outdated gems
  module OutdatedGems
    # Selects the most recent available versions (release i prerelease) for each gem
    # in the DB
    # @example
    #   result = Ruby::OutdatedGems::SelectMostRecentVersions.call(['karafka'])
    #   result['model'] #=> { "karafka" => ["1.2.11", "1.2.0.beta4"] }
    class SelectMostRecentVersions < ApplicationOperation
      step :select_rubygems
      step :select_most_recent_release_version
      step :select_most_recent_prerelease_version
      step :combine_results

      # How many gems at most we can return
      # Prevents from overusing this and loading really heavy queries
      MAX_GEMS_REQUESTED = 2_000

      private_constant :MAX_GEMS_REQUESTED

      # Selects gems and their ids
      # @param ctx [Trailblazer::Skill]
      # @param params [Array<String>] list of gems for which we want to get version
      def select_rubygems(ctx, params:, **)
        ctx['gems'] = Ruby::RubyGem
                      .where(name: params.first(MAX_GEMS_REQUESTED))
                      .select(:name, :id)
        ctx['gems_ids'] = ctx['gems'].map(&:id)
      end

      # Selects the most recent release for each requested gem
      # @param ctx [Trailblazer::Skill]
      # @param gems_ids [Array<Integer>] array with ids of gems in which we're interested
      def select_most_recent_release_version(ctx, gems_ids:, **)
        ctx['releases'] = \
          Ruby::RubyGem
          .select('rubygems.name, versions.number as number')
          .joins('INNER JOIN versions ON rubygems.id = versions.rubygem_id')
          .joins(
            '
              INNER JOIN gem_downloads
                ON versions.id = gem_downloads.version_id
                AND gem_downloads.version_id > 0
            '
          )
          .where(id: gems_ids)
          .where('latest IS TRUE')
          .where('yanked_at IS NULL')
          .where('prerelease is FALSE')
          .order('name ASC, versions.built_at DESC')
          .group_by(&:name)
          .transform_values!(&:first)
      end

      # Selects the most recent prerelease for each requested gem
      # @param ctx [Trailblazer::Skill]
      # @param gems_ids [Array<Integer>] array with ids of gems in which we're interested
      def select_most_recent_prerelease_version(ctx, gems_ids:, **)
        ctx['prereleases'] = \
          Ruby::RubyGem
          .select(
            '
              DISTINCT ON (rubygems.id) rubygems.id,
              rubygems.name,
              versions.number as number
            '
          )
          .joins('INNER JOIN versions ON rubygems.id = versions.rubygem_id')
          .joins(
            '
              INNER JOIN gem_downloads
                ON versions.id = gem_downloads.version_id
                AND gem_downloads.version_id > 0
            '
          )
          .where(id: gems_ids)
          .where('latest IS FALSE')
          .where('yanked_at IS NULL')
          .where('prerelease is TRUE')
          .order('rubygems.id ASC, versions.created_at DESC')
          .group_by(&:name)
          .transform_values!(&:first)
      end

      # Combines releases and prereleases into a final hash
      # @param ctx [Trailblazer::Skill]
      # @param gems [Array<Ruby::RubyGem>] gems we've selected
      # @param releases [Array<Ruby::RubyGem>] most recent releases
      # @param prereleases [Array<Ruby::RubyGem>] most recent prereleases
      def combine_results(ctx, gems:, releases:, prereleases:, **)
        ctx['model'] = gems.each_with_object({}) do |gem, accu|
          accu[gem.name] = [
            releases[gem.name]&.number,
            prereleases[gem.name]&.number
          ]
        end
      end
    end
  end
end
