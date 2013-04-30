source 'https://rubygems.org'

gem 'rails', '~> 3.2.12'
gem 'iqvoc', '~> 4.1.0'
gem 'iqvoc_skosxl', '~> 2.1.0'
gem 'iqvoc_inflectionals', '~> 2.1.0'
gem 'iqvoc_compound_forms', :git => 'git://github.com/innoq/iqvoc_compound_forms.git'
gem 'ruby-readability', :require => 'readability'
gem 'nokogiri', '~> 1.5.0'
gem 'pdf-reader', '~> 0.10.0'
gem 'workflow', '~> 1.0.0'

group :assets do
  gem 'uglifier'
end

group :development, :test do
  gem 'awesome_print'
  platforms :ruby do
    gem 'mysql2'
    gem 'sqlite3'

    gem 'pry'
    gem 'pry-rails'
    gem 'pry-debugger'
    gem 'pry-remote'
    gem 'hirb-unicode'
    gem 'cane'
  end
end

group :test do
  gem 'minitest'
  gem 'turn'
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
