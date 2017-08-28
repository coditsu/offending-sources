class RubyGemsDb < ApplicationRecord
  establish_connection RUBY_GEMS_DB

  def self.export_to_csv(target_file, query)
    username = RUBY_GEMS_DB['username']
    password = RUBY_GEMS_DB['password']
    database = RUBY_GEMS_DB['database']
    host = RUBY_GEMS_DB['host']
    port = RUBY_GEMS_DB['port']

    psql_cmd = "\\copy (#{query}) To '#{target_file}' With CSV"
    psql_run = "PGPASSWORD='#{password}' psql -h #{host} -U #{username} -p #{port} -d #{database} -c \"#{psql_cmd}\""
    system(psql_run)
  end
end
