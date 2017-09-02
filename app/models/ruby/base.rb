# frozen_string_literal: true

module Ruby
  # Base AR for all the models that interact with rubygems db
  class Base < ApplicationRecord
    establish_connection RUBY_GEMS_DB

    self.abstract_class = true

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
end
