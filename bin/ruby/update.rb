#!/usr/bin/ruby

require 'fileutils'
require 'csv'

REDOWNLOAD_DB = false
CURRENT_PATH = File.expand_path(File.dirname(__FILE__))
DB_FILENAME = File.join(CURRENT_PATH, 'latest.tar')
PUBLIC_PATH = File.join(CURRENT_PATH, '../../public')
UPDATE_SCRIPT = File.join(CURRENT_PATH, 'load-pg-dump.sh')

def sql_to_csv_export(target_file, query)
  FileUtils.rm_f(target_file)

  psql_cmd = "\\copy (#{query}) To '#{target_file}' With CSV"
  psql_run = "psql -U postgres -p 5433 -d rubygems -c \"#{psql_cmd}\""
  system(psql_run)
end

if REDOWNLOAD_DB
  system("#{UPDATE_SCRIPT} -c #{DB_FILENAME}")
  FileUtils.rm_f(DB_FILENAME)
end

gems_typosquatting_query = "
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
  INNER JOIN versions
    ON rubygems.id = versions.rubygem_id
  LEFT JOIN dependencies
    ON dependencies.scope = 'runtime' AND versions.id = dependencies.version_id
  LEFT JOIN rubygems rg2
    ON dependencies.rubygem_id = rg2.id
  GROUP BY rubygems.id, rg2.name
  ORDER by count desc
"

sql_to_csv_export(
  File.join(PUBLIC_PATH, 'ruby', 'gems_typosquatting_detector', 'sources.csv'),
  gems_typosquatting_query
)

licences_query = "
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

sql_to_csv_export(
  File.join(PUBLIC_PATH, 'ruby', 'gems_licenser', 'sources.csv'),
  licences_query
)

gems_count_query = "
  SELECT
    rubygems.name,
    SUM(gem_downloads.count) as count
  FROM
    rubygems
  INNER JOIN versions
    ON rubygems.id = versions.rubygem_id
  INNER JOIN gem_downloads
      ON versions.id = gem_downloads.version_id AND gem_downloads.version_id > 0
  GROUP by rubygems.id
  ORDER by count DESC
"

most_recent_non_pre_query = "
  SELECT
    rubygems.name,
    versions.number as number
  FROM
    rubygems
  INNER JOIN versions
    ON rubygems.id = versions.rubygem_id
  INNER JOIN gem_downloads
      ON versions.id = gem_downloads.version_id AND gem_downloads.version_id > 0
  WHERE latest IS TRUE AND yanked_at IS NULL AND prerelease is FALSE
  ORDER by name ASC
"

most_recent_pre_query = "
  SELECT
    DISTINCT ON (rubygems.id) rubygems.id,
    rubygems.name,
    versions.number as number
  FROM
    rubygems
  INNER JOIN versions
    ON rubygems.id = versions.rubygem_id
  INNER JOIN gem_downloads
      ON versions.id = gem_downloads.version_id AND gem_downloads.version_id > 0
  WHERE latest IS FALSE AND yanked_at IS NULL AND prerelease is TRUE
  ORDER by rubygems.id ASC, versions.created_at DESC
"

gems_count_path = File.join(PUBLIC_PATH, 'ruby', 'outdated_gems', 'gems_count.csv')
sql_to_csv_export(gems_count_path, gems_count_query)

most_recent_non_pre_path = File.join(PUBLIC_PATH, 'ruby', 'outdated_gems', 'most_recent_non_pre.csv')
sql_to_csv_export(most_recent_non_pre_path, most_recent_non_pre_query)

most_recent_pre_query_path = File.join(PUBLIC_PATH, 'ruby', 'outdated_gems', 'most_recent_pre.csv')
sql_to_csv_export(most_recent_pre_query_path, most_recent_pre_query)

# We need to preprocess the above stuff
# We will sort gems based on their popularity, as theirs a bigger change that we won't
# have to process everything

gems_counts = {}
CSV.foreach(gems_count_path) do |row|
  gems_counts[row[0]] = row[1].to_i
end

most_recent_non_pre = {}
CSV.foreach(most_recent_non_pre_path) do |row|
  most_recent_non_pre[row[0]] = row[1]
end

most_recent_pre = {}
CSV.foreach(most_recent_pre_query_path) do |row|
  most_recent_pre[row[1]] = row[2]
end

final = []

gems_counts.each do |gem, count|
  final << [gem, count, most_recent_non_pre[gem], most_recent_pre[gem]]
end

final.delete_if { |el| el[2].nil? && el[3].nil? }
final.sort! { |ar1, ar2| ar1[1] <=> ar2[1] }
final.reverse!

outdated_gems_path = File.join(PUBLIC_PATH, 'ruby', 'outdated_gems', 'sources.csv')

FileUtils.rm_f outdated_gems_path
FileUtils.rm_f gems_count_path
FileUtils.rm_f most_recent_non_pre_path
FileUtils.rm_f most_recent_pre_query_path

CSV.open(outdated_gems_path, "w") do |csv|
  final.each { |row| csv << [row[0], row[2], row[3]] }
end
