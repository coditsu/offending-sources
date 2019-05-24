# frozen_string_literal: true

namespace :app do
  desc 'Reloads Ruby database dump and regenerates our source current files'
  task reload_db: :environment do
    Ruby::ReloadDb.call
  end

  desc 'Reloads only the sources files, without reloading the whole database'
  task reload_sources: :environment do
    Ruby::ReloadSources.call({})
  end

  namespace :schema do
    desc 'Creates a schema for a RubyGems database'
    task dump: :environment do
      with_engine_connection do
        File.open(Rails.root.join('db', 'schema.rb'), 'w') do |file|
          ActiveRecord::SchemaDumper.dump ActiveRecord::Base.connection, file
        end
      end
    end

    desc 'Creates a database from schema'
    task load: :environment do
      parsed_yaml_database_configuration = YAML.load(
        ERB.new(
          File.read(Rails.root.join('config', 'databases', 'rubygems.yml'))
        ).result(binding)
      )
      ActiveRecord::Tasks::DatabaseTasks.database_configuration = parsed_yaml_database_configuration
      ActiveRecord::Base.configurations = ActiveRecord::Tasks::DatabaseTasks.database_configuration
      ActiveRecord::Tasks::DatabaseTasks.load_schema_current :ruby, Rails.root.join('db/schema.rb'), Rails.env.to_s
    end
  end
end

def with_engine_connection
  original = ActiveRecord::Base.remove_connection
  ActiveRecord::Base.establish_connection RUBY_GEMS_DB
  yield
ensure
  ActiveRecord::Base.establish_connection original
end
