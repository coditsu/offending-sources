# frozen_string_literal: true

module RubyGems
  module GemsLicenser
    class Reload < ApplicationOperation
      QUERY = "
        SELECT
          DISTINCT ON (rubygems.id)
          rubygems.name,
          replace(versions.licenses, E'\n' ,'|||') as versions
        FROM
          rubygems
        INNER JOIN
          versions ON rubygems.id = versions.rubygem_id
        WHERE latest IS TRUE AND yanked_at IS NULL
        ORDER BY
          rubygems.id, versions.updated_at::date DESC
      "

      FILENAME = 'current.csv'

      step :prepare_paths
      step :create_location
      step :cleanup
      step :fetch_and_store
      step :rename

      failure Macros::Error::Raise(Errors::OperationFailure)

      private

      def prepare_paths(options, **)
        options['location'] = sources_path.join(FILENAME)
        options['tmp'] = "#{options['location']}.tmp"
      end

      def create_location(options, location:, **)
        FileUtils.mkdir_p File.dirname(location)
      end

      def cleanup(options, tmp:, **)
        FileUtils.rm_f(tmp)
      end

      def fetch_and_store(options, tmp:, **)
        RubyGemsDb.export_to_csv(tmp, QUERY)
      end

      def rename(options, tmp:, location:, **)
        FileUtils.rm_f(location)
        FileUtils.mv(tmp, location)
      end
    end
  end
end
