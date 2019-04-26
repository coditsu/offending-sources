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
      step :extract_gems_with_versions
      step :prepare_search_scope
      step :select_licences_for_requested_versions
      step :select_licenses_for_the_most_recent
      step :combine_results

      failure Macros::Error::Raise(Errors::OperationFailure)

      private

      # Selects gems and their ids
      # @param ctx [Trailblazer::Skill]
      # @param params [Hash<String, String>] hash where we get the name of the gem and it's version
      def extract_gems_with_versions(ctx, params:, **)
        ctx['gems_with_versions'] = params.first(Settings.max_gems_per_request)
      end

      # Prepares the basic search scope that pics the licenses for requested gems
      # @param ctx [Trailblazer::Skill]
      def prepare_search_scope(ctx, **)
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
      end

      # Searches for licenses for the exact versions of gems that were requested
      # @param ctx [Trailblazer::Skill]
      # @param gems_with_versions [Array<Array<String, String>>] requested gems with versions
      def select_licences_for_requested_versions(ctx, gems_with_versions:, **)
        query = gems_with_versions
                .map { '(rubygems.name = ? AND versions.number = ?)' }
                .join(' OR ')

        ctx['requested'] = \
          ctx['search_scope']
          .where(query, *gems_with_versions.flatten)
          .each_with_object({}) { |gem, accu| accu[gem.name] = gem }
      end

      # Fallback method in case we were unable to find a license for requested gem version,
      #   then we pick the most recent license there is for those gems
      # @param ctx [Trailblazer::Skill]
      # @param gems_with_versions [Array<Array<String, String>>] requested gems with versions
      def select_licenses_for_the_most_recent(ctx, gems_with_versions:, **)
        ctx['most_recent'] = \
          ctx['search_scope']
          .order('rubygems.id, versions.updated_at::date DESC')
          .where('name IN (?)', gems_with_versions.map(&:first))
          .each_with_object({}) { |gem, accu| accu[gem.name] = gem }
      end

      # Combines fetched data into a hash where the key is the gem name and the value is
      #   the license
      # @param ctx [Trailblazer::Skill]
      # @param gems_with_versions [Array<Array<String, String>>] requested gems with versions
      # @param requested [Array<Ruby::RubyGem>] licenses for requested gems versions
      # @param most_recent [Array<Ruby::RubyGem>] fallback licenses from the most recent versions
      def combine_results(ctx, gems_with_versions:, requested:, most_recent:, **)
        ctx['model'] = gems_with_versions.each_with_object({}) do |gem_data, accu|
          name = gem_data.first
          # Don't include non-existing gems
          # Those may be gems that are private, etc
          next unless requested.key?(name) || most_recent.key?(name)

          accu[name] = (requested[name] || most_recent[name]).licenses
        end
      end
    end
  end
end
