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
    desc 'Migrates the your_engine database'
    task dump: :environment do
      with_engine_connection do
        File.open(File.expand_path('../../../db/schema.rb', __dir__), 'w') do |file|
          ActiveRecord::SchemaDumper.dump ActiveRecord::Base.connection, file
        end
      end
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
