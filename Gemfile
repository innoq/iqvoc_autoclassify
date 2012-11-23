source 'http://rubygems.org'

gem 'rails', '3.2.9'

gem 'iqvoc', '~> 4.0.2'
gem 'iqvoc_skosxl', '~> 2.0.1'
gem 'iqvoc_inflectionals', '~> 2.0.1'
gem 'iqvoc_compound_forms', '~> 2.0.2'

gem 'ruby-readability', :require => 'readability'
gem 'nokogiri', '~> 1.5.0'
gem 'pdf-reader', '~> 0.10.0'

group :assets do
  gem 'uglifier'
end

group :development, :test do
  gem 'awesome_print'
  platforms :ruby do
    gem 'mysql2'
    gem 'sqlite3'
    gem 'pry' # for interactive debugging
  end
  platforms :jruby do
    gem 'activerecord-jdbcmysql-adapter'
    gem 'activerecord-jdbcsqlite3-adapter'
  end
end

group :test do
  # gem 'minitest'
  # gem 'test-unit'
  gem 'capybara', '~> 1.1.2'
  gem 'database_cleaner'
  gem 'fakeweb'
  gem 'activerecord-oracle_enhanced-adapter', '~> 1.4.1', :platforms => :jruby
end

group :production do
  platforms :ruby do
    gem 'sqlite3'
  end

  platforms :jruby do
    gem 'activerecord-oracle_enhanced-adapter', '~> 1.4.1'
  end
end
