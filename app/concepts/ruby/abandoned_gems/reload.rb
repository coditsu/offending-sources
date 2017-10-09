# frozen_string_literal: true

module Ruby
  # Namespace for all the operations related to abandoned gems validator sources
  module AbandonedGems
    # Reloads sources file for abandoned gems validator engine
    # @note This command regenerates a different snapshot for each day, so date needs
    # to be provided
    # @example
    #  Ruby::AbandonedGems::Reload.call(day: Time.zone.today)
    class Reload < ApplicationOperation
      QUERY = ->(day) {
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
              WHERE yanked_at IS NULL AND built_at::date <= '#{day}'
              GROUP BY rubygem_id
            ) versions
          ON rubygems.id = versions.rubygem_id
        QUERY
      }

      step :fetch_day
      step :prepare_paths
      step :create_location
      step :fetch_and_store
      step :rename
      step :cleanup

      private

      # Prepares day date
      # @param options [Trailblazer::Operation::Option]
      # @param params [Hash] request hash with snapshotted at date
      def fetch_day(options, params:, **)
        options['day'] = params[:day] || Time.zone.today
      end

      # Prepares the path for a a snapshot of gem version up until certain day
      # @param options [Trailblazer::Operation::Option]
      # @param day [Date] date for which we will build most recent gems snapshot
      def prepare_paths(options, day:, **)
        options['model'] = sources_path.join("#{day}.csv")
        options['tmp'] = Tempfile.new
      end

      # Creates a location for files (if not existing)
      # @param _options [Trailblazer::Operation::Option]
      # @param model [String] path to a daily file
      def create_location(_options, model:, **)
        FileUtils.mkdir_p File.dirname(model)
      end

      # Executes our query and stores results in a tmp csv file
      # @param _options [Trailblazer::Operation::Option]
      # @param tmp [Tempfile] tmp file where we store our generated csv data
      # @param day [Date] day for which we want to generate outdated snapshot
      def fetch_and_store(_options, tmp:, day:, **)
        Ruby::Base.export_to_csv(tmp.path, QUERY.call(day))
      end

      # Renames and replaces our current sources file with data from tmp file
      # @param _options [Trailblazer::Operation::Option]
      # @param tmp [Tempfile] tmp file where we store our generated csv data
      # @param model [String] path to a daily file
      def rename(_options, tmp:, model:, **)
        FileUtils.rm_f(model)
        FileUtils.cp(tmp.path, model)
        true
      end

      # Removes a tmp file in case there were some leftovers from previous reload
      # @param _options [Trailblazer::Operation::Option]
      # @param tmp [Tempfile] tmp file we want to remove
      def cleanup(_options, tmp:, **)
        tmp.close
        tmp.unlink
      end
    end
  end
end
