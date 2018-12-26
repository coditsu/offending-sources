# frozen_string_literal: true

module Ruby
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
      step :fetch_and_store
      step :rename
      step :cleanup

      failure Macros::Error::Raise(Errors::OperationFailure)

      private

      # Prepares locations in which we will store our generated files and other tempfiles
      # @param ctx [Trailblazer::Skill]
      def prepare_paths(ctx, **)
        ctx['location'] = sources_path.join(FILENAME)
        ctx['tmp'] = Tempfile.new
      end

      # Creates a location for files (if not existing)
      # @param _ctx [Trailblazer::Skill]
      # @param location [Pathname] location of a target file
      def create_location(_ctx, location:, **)
        FileUtils.mkdir_p File.dirname(location)
      end

      # Executes our query and stores results in a tmp csv file
      # @param _ctx [Trailblazer::Skill]
      # @param tmp [Tempfile] tmp file where we store our generated csv data
      def fetch_and_store(_ctx, tmp:, **)
        ::Ruby::Base.export_to_csv(tmp.path, QUERY)
      end

      # Renames and replaces our current sources file with data from tmp file
      # @param _ctx [Trailblazer::Skill]
      # @param tmp [Tempfile] tmp file where we store our generated csv data
      # @param location [Pathname] target file location of the result csv data
      def rename(_ctx, tmp:, location:, **)
        FileUtils.rm_f(location)
        FileUtils.cp(tmp.path, location)
        true
      end

      # Removes a tmp file in case there were some leftovers from previous reload
      # @param _ctx [Trailblazer::Skill]
      # @param tmp [Tempfile] tmp file we want to remove
      def cleanup(_ctx, tmp:, **)
        tmp.close
        tmp.unlink
      end
    end
  end
end
