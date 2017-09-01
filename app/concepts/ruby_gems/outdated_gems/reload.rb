# frozen_string_literal: true

module RubyGems
  # Namespace for all the operations related to outdated gems validator sources
  module OutdatedGems
    # Reloads sources file for outdated gems validator engine
    # @note This command regenerates a different snapshot for each day, so date needs
    # to be previded
    # @example
    #  RubyGems::OutdatedGems::Reload.call(date_limit: Time.zone.today)
    class Reload < ApplicationOperation
      step :fetch_date_limit
      step :prepare_paths
      step :cleanup
      step :fetch_data
      step :load_data
      step :combine_data
      step :store
      step :rename
      step :cleanup

      # Simple struct for storing aggregated paths to files on which we work
      Paths = Struct.new(:count, :pre, :non_pre, :location, :tmp)

      private_constant :Paths

      private

      # Prepares date_limit date
      # @param options [Trailblazer::Operation::Option]
      # @param params [Hash] request hash with snapshotted at date
      def fetch_date_limit(options, params:, **)
        options['date_limit'] = params[:date_limit] || Time.zone.today
      end

      # Prepares all the paths to files that we will work on
      # @param options [Trailblazer::Operation::Option]
      # @param date_limit [Date] date for which we will build most recent gems snapshot
      def prepare_paths(options, date_limit:, **)
        base = "#{date_limit}.csv"
        options['paths'] = Paths.new(
          sources_path.join("count_#{base}"),
          sources_path.join("pre_#{base}"),
          sources_path.join("non_pre_#{base}"),
          sources_path.join(base.to_s),
          sources_path.join("#{base}.tmp")
        )
        true
      end

      # Removes all the leftover tempfiles that could exist after failed previous run
      # @param _options [Trailblazer::Operation::Option]
      # @param paths [RubyGems::OutdatedGems::Reload::Paths] paths struct with all the paths
      #   to files that we use in this operation
      def cleanup(_options, paths:, **)
        [
          paths.count,
          paths.pre,
          paths.non_pre,
          paths.tmp
        ].each { |path| FileUtils.rm_f path }
      end

      # Generates all the tmp csv files with partial data that we will merge in Ruby into one
      #   CSV file
      # @param _options [Trailblazer::Operation::Option]
      # @param date_limit [Date] date for which we will build most recent gems snapshot
      # @param paths [RubyGems::OutdatedGems::Reload::Paths] paths struct with all the paths
      #   to files that we use in this operation
      def fetch_data(_options, date_limit:, paths:, **)
        Base.export_to_csv(paths.count, count_query(date_limit))
        Base.export_to_csv(paths.pre, pre_query(date_limit))
        Base.export_to_csv(paths.non_pre, non_pre_query(date_limit))
      end

      # Loads csv data into memory, so we can work with it
      # @param options [Trailblazer::Operation::Option]
      # @param paths [RubyGems::OutdatedGems::Reload::Paths] paths struct with all the paths
      #   to files that we use in this operation
      def load_data(options, paths:, **)
        counts = {}
        pre = {}
        non_pre = {}

        CSV.foreach(paths.count) { |row| counts[row[0]] = row[1].to_i }
        CSV.foreach(paths.pre) { |row| pre[row[1]] = row[2].to_i }
        CSV.foreach(paths.non_pre) { |row| pre[row[0]] = row[1].to_i }

        options['counts'] = counts
        options['pre'] = pre
        options['non_pre'] = non_pre
      end

      # Combines partial data into a single array with details that we need
      # @param options [Trailblazer::Operation::Option]
      # @param counts [Hash] gem download counts
      # @param pre [Hash] most recent prerelease for a given day
      # @param non_pre [Hash] most recent release for a given day
      def combine_data(options, counts:, pre:, non_pre:, **)
        results = counts.map do |gem, count|
          [gem, count, non_pre[gem], pre[gem]]
        end

        options['results'] = results.tap do |result|
          result.delete_if { |el| el[2].nil? && el[3].nil? }
          result.sort! { |ar1, ar2| ar1[1] <=> ar2[1] }
          result.reverse!
        end
      end

      # Persists all the details into tmp combined csv file
      # @param _options [Trailblazer::Operation::Option]
      # @param results [Array<Array>] array with combined details
      # @param paths [RubyGems::OutdatedGems::Reload::Paths] paths struct with all the paths
      #   to files that we use in this operation
      def store(_options, results:, paths:, **)
        CSV.open(paths.tmp, 'w') do |csv|
          results.each { |row| csv << [row[0], row[2], row[3]] }
        end
      end

      # Removes the previous target file and replaces it with our newly generated tmp file
      # @param _options [Trailblazer::Operation::Option]
      # @param paths [RubyGems::OutdatedGems::Reload::Paths] paths struct with all the paths
      #   to files that we use in this operation
      def rename(_options, paths:, **)
        FileUtils.rm_f(paths.location)
        FileUtils.mv(paths.tmp, paths.location)
      end

      # @param date_limit [Date] day up until we calculate
      # @return [String] query that will return us gem name and number of downloads till
      #   certain point it history
      def count_query(date_limit = Time.zone.today)
        "
          SELECT rubygems.name, SUM(gem_downloads.count) as count
          FROM rubygems
          INNER JOIN versions
            ON rubygems.id = versions.rubygem_id
          INNER JOIN gem_downloads
              ON versions.id = gem_downloads.version_id
                AND gem_downloads.version_id > 0
                AND versions.built_at::date <= '#{date_limit}'
          GROUP by rubygems.id
          ORDER by count DESC
        "
      end

      # @param date_limit [Date] day up until we calculate
      # @return [String] query that returns most recent non pre release that has been
      #   available at a given time
      def non_pre_query(date_limit = Time.zone.today)
        "
          SELECT rubygems.name, versions.number as number
          FROM rubygems
          INNER JOIN versions
            ON rubygems.id = versions.rubygem_id
          INNER JOIN gem_downloads
              ON versions.id = gem_downloads.version_id
                AND gem_downloads.version_id > 0
                AND versions.built_at::date <= '#{date_limit}'
          WHERE latest IS TRUE
            AND yanked_at IS NULL
            AND prerelease is FALSE
          ORDER by name ASC
        "
      end

      # @param date_limit [Date] day up until we calculate
      # @return [String] query that returns most recent pre release that has been
      #   available at a given time
      def pre_query(date_limit = Time.zone.today)
        "
          SELECT
            DISTINCT ON (rubygems.id) rubygems.id,
            rubygems.name,
            versions.number as number
          FROM rubygems
          INNER JOIN versions
            ON rubygems.id = versions.rubygem_id
          INNER JOIN gem_downloads
              ON versions.id = gem_downloads.version_id
                AND gem_downloads.version_id > 0
                AND versions.built_at::date <= '#{date_limit}'
          WHERE latest IS FALSE AND yanked_at IS NULL AND prerelease is TRUE
          ORDER by rubygems.id ASC, versions.created_at DESC
        "
      end
    end
  end
end
