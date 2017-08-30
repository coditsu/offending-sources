# frozen_string_literal: true

# Model that acts as a binder for raw sql commands execution on a rubygems database
class RubyGemsDb < ApplicationRecord
  establish_connection RUBY_GEMS_DB

  # Exports a data returned by the query to a given file using postgres copy function
  # @param target_file [String] path to a file to which we should save generated results
  # @param query [String] query that will generate the data
  def self.export_to_csv(target_file, query)
    username = RUBY_GEMS_DB['username']
    password = RUBY_GEMS_DB['password']
    database = RUBY_GEMS_DB['database']
    host = RUBY_GEMS_DB['host']
    port = RUBY_GEMS_DB['port']

    psql_function = "\\copy (#{query}) To '#{target_file}' With CSV"

    system [
      "PGPASSWORD='#{password}'",
      'psql',
      "-h #{host}",
      "-U #{username}",
      "-p #{port}",
      "-d #{database}",
      "-c \"#{psql_function}\""
    ].join(' ')
  end
end
