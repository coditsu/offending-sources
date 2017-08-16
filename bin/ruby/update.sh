#!/bin/bash
set -e

CURRENT_PATH="$( cd "$( dirname "${BASH_SOURCE[0]}" )" && pwd )"
DB_NAME="$CURRENT_PATH/latest.tar"
PUBLIC_PATH="$CURRENT_PATH/../../public"

$CURRENT_PATH/load-pg-dump.sh -c $DB_NAME

csv_export () {
  file_target="$2.csv"
  rm -f $file_target
  cmd="\copy ($1) To '$file_target' With CSV"
  echo $cmd
  psql -U postgres -p 5433 -d rubygems -c "$cmd"
}

# This query extracts gems, number of downloads and their dependencies for gemfile_typos_detector
gem_typos="
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
      ON rubygems.id = versions.rubygem_id AND versions.yanked_at IS NULL
    INNER JOIN gem_downloads
      ON versions.id = gem_downloads.version_id AND gem_downloads.version_id > 0
    WHERE count > 20000
    GROUP by rubygems.id
    ORDER BY count desc
  ) popu ON popu.id = rubygems.id
  INNER JOIN versions ON rubygems.id = versions.rubygem_id
  LEFT JOIN dependencies ON dependencies.scope = 'runtime' AND versions.id = dependencies.version_id
  LEFT JOIN rubygems rg2 ON dependencies.rubygem_id = rg2.id
  GROUP BY rubygems.id, rg2.name
  ORDER by count desc
"

csv_export "$gem_typos" "$CURRENT_PATH/with_dependencies_and_count"

versions="
  SELECT
    rubygems.name,
    string_agg(versions.number, '|') AS numbers
  FROM
    rubygems
  INNER JOIN versions ON rubygems.id = versions.rubygem_id
  GROUP by rubygems.id
"

licences="
  SELECT
    DISTINCT ON (rubygems.id)
    rubygems.name,
    replace(versions.licenses, E'\n' ,'|||') as versions
  FROM
    rubygems
  INNER JOIN
    versions ON rubygems.id = versions.rubygem_id
  WHERE latest IS TRUE AND yanked_at IS  NULL
  ORDER BY
    rubygems.id, versions.updated_at::date DESC
"

csv_export "$licences" "$CURRENT_PATH/with_licences"

rm -f "$PUBLIC_PATH/ruby/gems_typosquatting_detector/sources.csv"
rm -f "$PUBLIC_PATH/ruby/gems_licenser/sources.csv"

mv "$CURRENT_PATH/with_dependencies_and_count.csv" "$PUBLIC_PATH/ruby/gems_typosquatting_detector/sources.csv"
mv "$CURRENT_PATH/with_licences.csv" "$PUBLIC_PATH/ruby/gems_licenser/sources.csv"

rm -f $DB_NAME
