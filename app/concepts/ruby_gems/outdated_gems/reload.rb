# frozen_string_literal: true

module RubyGems
  # Namespace for all the operations related to outdated gems validator sources
  module OutdatedGems
    # Reloads sources file for outdated gems validator engine
    # @note This command regenerates a different snapshot for each day, so date needs
    # to be previded
    # @example
    #  RubyGems::OutdatedGems::Reload.call(snapshotted_at: Date.today)
    class Reload < ApplicationOperation
      step :fetch_snapshotted_at
      step :prepare_paths
      step :cleanup
      step :fetch_data
      step :load_data
      step :combine_data
      step :store
      step :rename
      step :cleanup

      private

      # Prepares snapshotted_at date
      # @param options [Trailblazer::Operation::Option]
      # @param params [Hash] request hash with snapshotted at date
      def fetch_snapshotted_at(options, params:, **)
        options['snapshotted_at'] = params[:snapshotted_at] || Date.today
      end

      # Prepares all the paths to files that we will work on
      # @param options [Trailblazer::Operation::Option]
      # @param snapshotted_at [Date] date for which we will build most recent gems snapshot
      def prepare_paths(options, snapshotted_at:, **)
        base = "#{snapshotted_at}.csv"
        options['count_path'] = sources_path.join("count_#{base}")
        options['pre_path'] = sources_path.join("pre_#{base}")
        options['non_pre_path'] = sources_path.join("non_pre_#{base}")
        options['location'] = sources_path.join(base.to_s)
        options['tmp'] = sources_path.join("#{base}.tmp")
      end

      # Removes all the leftover tempfiles that could exist after failed previous run
      # @param _options [Trailblazer::Operation::Option]
      # @param count_path [Pathname] gems downloads count tmp file path
      # @param pre_path [Pathname] prereleases tmp file path
      # @param non_pre_path [Pathname] non prereleases tmp file path
      # @param tmp [Pathname] path to a tmp file where we will store generated results
      def cleanup(_options, count_path:, pre_path:, non_pre_path:, tmp:, **)
        [
          count_path,
          pre_path,
          non_pre_path,
          tmp
        ].each { |path| FileUtils.rm_f path }
      end

      # Generates all the tmp csv files with partial data that we will merge in Ruby into one
      #   CSV file
      # @param _options [Trailblazer::Operation::Option]
      # @param snapshotted_at [Date] date for which we will build most recent gems snapshot
      # @param count_path [Pathname] gems downloads count tmp file path
      # @param pre_path [Pathname] prereleases tmp file path
      # @param non_pre_path [Pathname] non prereleases tmp file path
      def fetch_data(_options, snapshotted_at:, count_path:, pre_path:, non_pre_path:, **)
        RubyGemsDb.export_to_csv(count_path, count_query(snapshotted_at))
        RubyGemsDb.export_to_csv(pre_path, pre_query(snapshotted_at))
        RubyGemsDb.export_to_csv(non_pre_path, non_pre_query(snapshotted_at))
      end

      # Loads csv data into memory, so we can work with it
      # @param options [Trailblazer::Operation::Option]
      # @param snapshotted_at [Date] date for which we will build most recent gems snapshot
      # @param count_path [Pathname] gems downloads count tmp file path
      # @param pre_path [Pathname] prereleases tmp file path
      # @param non_pre_path [Pathname] non prereleases tmp file path
      def load_data(options, snapshotted_at:, count_path:, pre_path:, non_pre_path:, **)
        counts = {}
        pre = {}
        non_pre = {}

        CSV.foreach(count_path) { |row| counts[row[0]] = row[1].to_i }
        CSV.foreach(pre_path) { |row| pre[row[1]] = row[2].to_i }
        CSV.foreach(non_pre_path) { |row| pre[row[0]] = row[1].to_i }

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
      # @param tmp [Pathname] path to a tmp file where we will store generated results
      def store(_options, results:, tmp:, **)
        CSV.open(tmp, "w") do |csv|
          results.each { |row| csv << [row[0], row[2], row[3]] }
        end
      end

      # Removes the previous target file and replaces it with our newly generated tmp file
      # @param _options [Trailblazer::Operation::Option]
      # @param tmp [Pathname] path to a tmp file where we will store generated results
      def rename(_options, tmp:, location:, **)
        FileUtils.rm_f(location)
        FileUtils.mv(tmp, location)
      end

      def count_query(snapshotted_at = Date.today)
        "
          SELECT
            rubygems.name,
            SUM(gem_downloads.count) as count
          FROM
            rubygems
          INNER JOIN versions
            ON rubygems.id = versions.rubygem_id
          INNER JOIN gem_downloads
              ON versions.id = gem_downloads.version_id
                AND gem_downloads.version_id > 0
                AND versions.built_at::date <= '#{snapshotted_at}'
          GROUP by rubygems.id
          ORDER by count DESC
        "
      end

      def non_pre_query(snapshotted_at = Date.today)
        "
          SELECT
            rubygems.name,
            versions.number as number
          FROM
            rubygems
          INNER JOIN versions
            ON rubygems.id = versions.rubygem_id
          INNER JOIN gem_downloads
              ON versions.id = gem_downloads.version_id
                AND gem_downloads.version_id > 0
                AND versions.built_at::date <= '#{snapshotted_at}'
          WHERE latest IS TRUE
            AND yanked_at IS NULL
            AND prerelease is FALSE
          ORDER by name ASC
        "
      end

      def pre_query(snapshotted_at = Date.today)
        "
          SELECT
            DISTINCT ON (rubygems.id) rubygems.id,
            rubygems.name,
            versions.number as number
          FROM
            rubygems
          INNER JOIN versions
            ON rubygems.id = versions.rubygem_id
          INNER JOIN gem_downloads
              ON versions.id = gem_downloads.version_id
                AND gem_downloads.version_id > 0
                AND versions.built_at::date <= '#{snapshotted_at}'
          WHERE latest IS FALSE
            AND yanked_at IS NULL
            AND prerelease is TRUE
          ORDER by rubygems.id ASC, versions.created_at DESC
        "
      end
    end
  end
end
