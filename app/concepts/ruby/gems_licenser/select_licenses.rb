# frozen_string_literal: true

module Ruby
  # Namespace for all the operations related to gems licenser sources
  module GemsLicenser
    # Selects licenses for given versions of given gems
    # @example
    #   gems = { 'nokogiri' => '1.0.0' }
    #   result = Ruby::GemsLicenser::SelectLicenses.call(gems)
    #   result['model'] #=> { "nokogiri"=>"---|||- MIT|||" }
    class SelectLicenses < ApplicationOperation
      step :select_rubygems
      step :prepare_search_scope
      step :select_licences_for_requested_versions
      step :select_licenses_for_the_most_recent
      step :combine_results

      failure Macros::Error::Raise(Errors::OperationFailure)

      private

      # Selects gems and their ids
      # @param ctx [Trailblazer::Skill]
      # @param params [Hash<String, String>] hash where we get the name of the gem and it's version
      def select_rubygems(ctx, params:, **)
        ctx['gems'] = Ruby::RubyGem
                      .where(name: params.keys.first(Settings.max_gems_per_request))
                      .select(:name, :id)
        ctx['gems_ids'] = ctx['gems'].map(&:id)
        ctx['versions'] = params.values
      end

      # Prepares the basic search scope that pics the licenses for requested gems
      # @param ctx [Trailblazer::Skill]
      # @param gems_ids [Array<Integer>] array with ids of gems in which we're interested
      def prepare_search_scope(ctx, gems_ids:, **)
        ctx['search_scope'] = \
          Ruby::RubyGem
          .select(
            "
              DISTINCT ON (rubygems.id)
              rubygems.name,
              versions.number as version,
              replace(versions.licenses, E'\n' ,'|||') as licenses
            "
          )
          .joins('INNER JOIN versions ON rubygems.id = versions.rubygem_id')
          .where('yanked_at IS NULL')
          .where(id: gems_ids)
          .order('rubygems.id, versions.updated_at::date DESC')
      end

      # Searches for licenses for the exact versions of gems that were requested
      # @param ctx [Trailblazer::Skill]
      # @param versions [Array<String>] requested gem versions
      def select_licences_for_requested_versions(ctx, versions:, **)
        ctx['requested'] = \
          ctx['search_scope']
          .where('versions.number IN (?)', versions)
          .each_with_object({}) { |gem, accu| accu[gem.name] = gem }
      end

      # Fallback method in case we were unable to find a license for requested gem version,
      #   then we pick the most recent license there is for those gems
      # @param ctx [Trailblazer::Skill]
      def select_licenses_for_the_most_recent(ctx, **)
        ctx['most_recent'] = \
          ctx['search_scope']
          .each_with_object({}) { |gem, accu| accu[gem.name] = gem }
      end

      # Combines fetched data into a hash where the key is the gem name and the value is
      #   the license
      # @param ctx [Trailblazer::Skill]
      # @param gems [Array<Ruby::RubyGem>] gems we've requested
      # @param requested [Array<Ruby::RubyGem>] licenses for requested gems versions
      # @param most_recent [Array<Ruby::RubyGem>] fallback licenses from the most recent versions
      def combine_results(ctx, gems:, requested:, most_recent:, **)
        ctx['model'] = gems.each_with_object({}) do |gem, accu|
          accu[gem.name] = (requested[gem.name] || most_recent[gem.name])&.licenses
        end
      end
    end
  end
end
