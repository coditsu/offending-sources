# frozen_string_literal: true

module Ruby
  # Namespace for all the operations related to abandoned gems validator sources
  module AbandonedGems
    # Reloads sources file for abandoned gems validator engine
    # @example
    #  Ruby::AbandonedGems::Reload.call
    class Reload < ApplicationOperation
      # Query used to extract the date of the last update of all the gems on a particular date
      QUERY = lambda {
        <<~QUERY
          SELECT
            name,
            built_at
          FROM
            rubygems
          JOIN
            (
              SELECT rubygem_id, MAX(built_at) built_at
              FROM versions
              WHERE yanked_at IS NULL
              GROUP BY rubygem_id
            ) versions
          ON rubygems.id = versions.rubygem_id
        QUERY
      }

      # Name of the file in which we will store licenses details
      FILENAME = 'current.csv'

      step :prepare_paths
      step :create_location
      step :fetch_and_store
      step :rename
      step :cleanup

      private

      # Prepares the path for a a snapshot of gem version
      # @param ctx [Trailblazer::Skill]
      def prepare_paths(ctx, **)
        ctx['model'] = sources_path.join(FILENAME)
        ctx['tmp'] = Tempfile.new
      end

      # Creates a location for files (if not existing)
      # @param _ctx [Trailblazer::Skill]
      # @param model [String] path to a daily file
      def create_location(_ctx, model:, **)
        FileUtils.mkdir_p File.dirname(model)
      end

      # Executes our query and stores results in a tmp csv file
      # @param _ctx [Trailblazer::Skill]
      # @param tmp [Tempfile] tmp file where we store our generated csv data
      def fetch_and_store(_ctx, tmp:, **)
        Ruby::Base.export_to_csv(tmp.path, QUERY.call)
      end

      # Renames and replaces our current sources file with data from tmp file
      # @param _ctx [Trailblazer::Skill]
      # @param tmp [Tempfile] tmp file where we store our generated csv data
      # @param model [String] path to a daily file
      def rename(_ctx, tmp:, model:, **)
        FileUtils.rm_f(model)
        FileUtils.cp(tmp.path, model)
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
