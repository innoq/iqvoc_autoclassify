source 'http://rubygems.org'

gem 'rails', '3.2.8'

gem 'iqvoc', '~> 4.0.2'
gem 'iqvoc_skosxl', '~> 2.0.1'
gem 'iqvoc_inflectionals', '~> 2.0.1'
gem 'iqvoc_compound_forms', '~> 2.0.2'

gem 'ruby-readability', :require => 'readability'
gem 'nokogiri', '~> 1.5.0'
gem 'pdf-reader', '~> 0.10.0'

group :development do
  gem 'awesome_print'
end

group :assets do
  gem 'uglifier'
end

group :development, :test do
  platforms :ruby do
    gem 'sqlite3'
    gem 'pry' # for interactive debugging
  end
  platforms :jruby do
    gem 'activerecord-jdbcsqlite3-adapter'
  end
end

group :test do
  gem 'test-unit'
  gem 'capybara'
  gem 'database_cleaner'
  gem 'fakeweb'
  gem 'spork'
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
