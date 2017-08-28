# frozen_string_literal: true

module RubyGems
  # Namespace for all the operations related to gems licenser sources
  module GemsLicenser
    # Reloads sources file for gems licenser offending engine
    # This file contains informations about licenses of gems that we use
    class Reload < ApplicationOperation
      # Query used to extract licenses details from rubygems database
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

      # Name of the file in which we will store licenses details
      FILENAME = 'current.csv'

      step :prepare_paths
      step :create_location
      step :cleanup
      step :fetch_and_store
      step :rename

      failure Macros::Error::Raise(Errors::OperationFailure)

      private

      # Prepares locations in which we will store our generated files and other tempfiles
      # @param options [Trailblazer::Operation::Option]
      def prepare_paths(options, **)
        options['location'] = sources_path.join(FILENAME)
        options['tmp'] = "#{options['location']}.tmp"
      end

      # Creates a location for files (if not existing)
      # @param _options [Trailblazer::Operation::Option]
      # @param location [Pathname] location of a target file
      def create_location(_options, location:, **)
        FileUtils.mkdir_p File.dirname(location)
      end

      # Removes a tmp file in case there were some leftovers from previous reload
      # @param _options [Trailblazer::Operation::Option]
      # @param tmp [Pathname] path to a tmp file we want to remove
      def cleanup(_options, tmp:, **)
        FileUtils.rm_f(tmp)
      end

      # Executes our query and stores results in a tmp csv file
      # @param _options [Trailblazer::Operation::Option]
      # @param tmp [Pathname] path to a tmp where we will store our generated csv data
      def fetch_and_store(_options, tmp:, **)
        RubyGemsDb.export_to_csv(tmp, QUERY)
      end

      # Renames and replaces our current sources file with data from tmp file
      # @param _options [Trailblazer::Operation::Option]
      # @param tmp [Pathname] tmp file that we will renamed
      # @param location [Pathname] target file location of the result csv data
      def rename(_options, tmp:, location:, **)
        FileUtils.rm_f(location)
        FileUtils.mv(tmp, location)
      end
    end
  end
end
