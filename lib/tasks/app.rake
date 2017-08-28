namespace :app do
  desc 'Reloads RubyGems database dump and regenerates our source current files'
  task reload: :environment do
    username = RUBY_GEMS_DB['username']
    password = RUBY_GEMS_DB['password']
    database = RUBY_GEMS_DB['database']
    host = RUBY_GEMS_DB['host']
    port = RUBY_GEMS_DB['port']

    cmd = [
      "DB_USERNAME=#{username}",
      "DB_PASSWORD='#{password}'",
      "DB_HOST=#{host}",
      "DB_PORT=#{port}",
      "DB_NAME=#{database}",
      File.join(Rails.root, 'bin', 'rubygems', 'reload.sh download')
    ]

    system(cmd.join(' '))

    RubyGems::GemsLicenser::Reload.call({})
    RubyGems::GemsTyposquattingDetector::Reload.call({})
    RubyGems::OutdatedGems::Reload.call({})
  end
end
