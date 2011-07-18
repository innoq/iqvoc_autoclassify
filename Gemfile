source "http://rubygems.org"

gemspec

gem 'rails', '3.0.9'

gem 'iqvoc', :path => '../iqvoc'
gem 'iqvoc_skosxl', :path => '../iqvoc_skosxl'

# Hotfix for the problem of engine/plugin helpers not being mixed in.
# https://rails.lighthouseapp.com/projects/8994/tickets/1905-apphelpers-within-plugin-not-being-mixed-in
# http://github.com/drogus/rails_helpers_fix
gem 'rails_helpers_fix'

group :development do
end

group :development, :test do
  platforms :ruby do
    gem 'mysql2', '0.2.7'
  end
  platforms :jruby do
    gem 'activerecord-jdbcmysql-adapter'
  end
end

group :test do
  gem 'nokogiri', '1.4.3.1'
  gem 'capybara'
  gem 'database_cleaner', '0.6.0.rc.3'
  gem 'factory_girl_rails'
  gem 'spork', '~> 0.9.0.rc'
  gem 'spork-testunit'
end

group :production, :production_internal do
  platforms :ruby do
    gem 'sqlite3'
  end

  platforms :jruby do
    gem 'activerecord-oracle_enhanced-adapter'
  end
end
