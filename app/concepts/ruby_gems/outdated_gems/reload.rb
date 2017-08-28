# frozen_string_literal: true
require 'csv'

module RubyGems
  module OutdatedGems
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

      def fetch_snapshotted_at(options, params:, **)
        options['snapshotted_at'] = params[:snapshotted_at]
      end

      def prepare_paths(options, snapshotted_at:, **)
        base = "#{snapshotted_at}.csv"
        options['count_path'] = sources_path.join("count-#{base}")
        options['non_pre_path'] = sources_path.join("non_pre-#{base}")
        options['pre_path'] = sources_path.join("pre_-#{base}")
        options['location'] = sources_path.join("#{base}")
        options['tmp'] = sources_path.join("#{base}.tmp")
      end

      def cleanup(options, count_path:, pre_path:, non_pre_path:, **)
        FileUtils.rm_f count_path
        FileUtils.rm_f pre_path
        FileUtils.rm_f non_pre_path
      end

      def fetch_data(options, snapshotted_at:, count_path:, pre_path:, non_pre_path:, **)
        RubyGemsDb.export_to_csv(count_path, count_query(snapshotted_at))
        RubyGemsDb.export_to_csv(pre_path, pre_query(snapshotted_at))
        RubyGemsDb.export_to_csv(non_pre_path, non_pre_query(snapshotted_at))
        true
      end

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

      def store(options, results:, tmp:, **)
        CSV.open(tmp, "w") do |csv|
          results.each { |row| csv << [row[0], row[2], row[3]] }
        end
      end

      def rename(options, tmp:, location:, **)
        FileUtils.rm_f(location)
        FileUtils.mv(tmp, location)
      end

      def count_query(date = Date.today)
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
                AND versions.built_at::date <= '#{date}'
          GROUP by rubygems.id
          ORDER by count DESC
        "
      end

      def non_pre_query(date = Date.today)
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
                AND versions.built_at::date <= '#{date}'
          WHERE latest IS TRUE
            AND yanked_at IS NULL
            AND prerelease is FALSE
          ORDER by name ASC
        "
      end

      def pre_query(date = Date.today)
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
                AND versions.built_at::date <= '#{date}'
          WHERE latest IS FALSE
            AND yanked_at IS NULL
            AND prerelease is TRUE
          ORDER by rubygems.id ASC, versions.created_at DESC
        "
      end
    end
  end
end
