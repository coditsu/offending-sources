# frozen_string_literal: true

module Ruby
  # Namespace for all the operations related to gems typosquatting detector sources
  module GemsTyposquattingDetector
    # Reloads sources file for gems typosquatting offending engine
    # This file contains informations about licenses of gems that we use
    class Reload < ApplicationOperation
      # Query that we use to generate target csv file
      # It contains details about names, dependencies and number of downloads of gems
      QUERY = "
        SELECT
          rubygems.name,
          rg2.name as dep_name,
          MIN(popu.count) as count
        FROM
          rubygems
        INNER JOIN (
          SELECT rubygems.id, SUM(gem_downloads.count) as count
          FROM rubygems
          INNER JOIN versions
            ON rubygems.id = versions.rubygem_id
          INNER JOIN gem_downloads
            ON versions.id = gem_downloads.version_id
              AND gem_downloads.version_id > 0
          WHERE count > 20000
          GROUP by rubygems.id
          ORDER BY count desc
        ) popu ON popu.id = rubygems.id
        INNER JOIN versions
          ON rubygems.id = versions.rubygem_id
        LEFT JOIN dependencies
          ON dependencies.scope = 'runtime'
            AND versions.id = dependencies.version_id
        LEFT JOIN rubygems rg2
          ON dependencies.rubygem_id = rg2.id
        GROUP BY rubygems.id, rg2.name
        ORDER by count desc
      "

      # Name of the file in which we will store gems details
      FILENAME = 'current.csv'

      step :prepare_paths
      step :create_location
      step :fetch_and_store
      step :update
      step :cleanup

      private

      # Prepares locations in which we will store our generated files and other temp files
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
        Ruby::Base.export_to_csv(tmp.path, QUERY)
      end

      # Renames and replaces our current sources file with data from tmp file
      # @param _ctx [Trailblazer::Skill]
      # @param tmp [Tempfile] tmp file where we store our generated csv data
      # @param location [Pathname] target file location of the result csv data
      def update(_ctx, tmp:, location:, **)
        FileUtils.rm_f(location)
        FileUtils.cp(tmp.path, location)
        true
      end

      # Removes a tmp file in case there were some leftovers from previous reload
      # @param _ctx [Trailblazer::Skill]
      # @param tmp [Tempfile] tmp file where we store our generated csv data
      def cleanup(_ctx, tmp:, **)
        tmp.close
        tmp.unlink
      end
    end
  end
end
