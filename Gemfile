source "http://rubygems.org"

gem 'rails', '3.1.3'

gem 'iqvoc', :path => '../iqvoc'
gem 'iqvoc_skosxl', :path => '../iqvoc_skosxl'
gem 'iqvoc_umt', :path => '../iqvoc_umt'

gem 'ruby-readability', :require => 'readability'
gem 'nokogiri', '1.5.0'
gem 'pdf-reader', '~> 0.10.0'

group :development do
  gem 'awesome_print'
end

group :assets do
  gem 'uglifier'
end

group :development, :test do
  platforms :ruby do
    gem 'mysql2'
  end
  platforms :jruby do
    gem 'activerecord-jdbcmysql-adapter'
  end
end

group :test do
  gem 'capybara'
  gem 'database_cleaner'
  gem 'fakeweb'
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
