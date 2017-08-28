# frozen_string_literal: true

module RubyGems
  module GemsTyposquattingDetector
    class Reload < ApplicationOperation
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
              AND versions.yanked_at IS NULL
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

      step :prepare_location
      step :delete_tmp_if_existing
      step :fetch_and_store
      step :rename

      private

      def prepare_location(options, **)
        options['location'] = sources_path.join(FILENAME)
        options['tmp'] = options['location'] + '.tmp'
      end

      def delete_tmp_if_existing(options, tmp:, **)
        FileUtils.rm_f(tmp)
      end

      def fetch_and_store(options, tmp:, **)
        RubyGemsDb.export_to_csv(tmp, QUERY)
        true
      end

      def rename(options, tmp:, location:, **)
        FileUtils.rm_f(location)
        FileUtils.mv(tmp, location)
      end
    end
  end
end
