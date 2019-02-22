# frozen_string_literal: true

module Ruby
  # Namespace for things related to tracking outdated gems
  module AbandonedGems
    # Selects the last release date for requested gems
    # @example
    #   result = Ruby::AbandonedGems::SelectLastReleasedDates.call(['karafka'])
    #   result['model'] #=> { "karafka" => '2018-01-02 12:12:12' }
    class SelectLastReleasedDates < ApplicationOperation
      step :select_rubygems
      step :select_most_recent_releases
      step :combine_results

      failure Macros::Error::Raise(Errors::OperationFailure)

      # Selects gems and their ids
      # @param ctx [Trailblazer::Skill]
      # @param params [Array<String>] list of gems for which we want to get version
      def select_rubygems(ctx, params:, **)
        ctx['gems'] = Ruby::RubyGem
                      .where(name: params.first(Settings.max_gems_per_request))
                      .select(:name, :id)
        ctx['gems_ids'] = ctx['gems'].map(&:id)
      end

      # @param ctx [Trailblazer::Skill]
      # @param gems_ids [Array<Integer>] array with ids of gems in which we're interested
      def select_most_recent_releases(ctx, gems_ids:, **)
        versions = ::Ruby::Version
                   .select('rubygem_id, MAX(built_at) built_at')
                   .where('yanked_at IS NULL')
                   .where(rubygem_id: gems_ids)
                   .group(:rubygem_id)

        join_statement = "JOIN (#{versions.to_sql}) versions ON rubygems.id = versions.rubygem_id"

        ctx['dates'] = Ruby::RubyGem
                       .select('name, built_at')
                       .joins(join_statement)
                       .where(id: gems_ids)
      end

      # Combines releases and prereleases into a final hash
      # @param ctx [Trailblazer::Skill]
      # @param dates [Array<Ruby::RubyGem>] most recent release details
      def combine_results(ctx, dates:, **)
        ctx['model'] = dates.each_with_object({}) do |gem, accu|
          accu[gem.name] = gem.built_at
        end
      end
    end
  end
end
