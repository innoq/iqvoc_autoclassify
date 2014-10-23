source 'https://rubygems.org'

gem 'iqvoc', '~> 4.6.0', :github => 'innoq/iqvoc'
gem 'iqvoc_skosxl', '~> 2.5.0', :github => 'innoq/iqvoc_skosxl'
gem 'iqvoc_inflectionals', '~> 2.5.0', :github => 'innoq/iqvoc_inflectionals'
gem 'iqvoc_compound_forms', '~> 2.5.0', :github => 'innoq/iqvoc_compound_forms'

gem 'ruby-readability', :require => 'readability'
gem 'nokogiri', '~> 1.5.0'
gem 'pdf-reader', '~> 0.10.0'
gem 'workflow', '~> 1.0.0'
gem 'guess_html_encoding'
gem 'apipie-rails', '0.1.3'

group :development, :test do
  gem 'awesome_print'
  gem 'spring'
  gem 'pry-rails'

  platforms :ruby do
    gem 'mysql2'
    gem 'sqlite3'
  end

  platforms :jruby do
    gem 'activerecord-jdbcmysql-adapter'
    gem 'activerecord-jdbcsqlite3-adapter'
  end
end

group :test do
  gem 'capybara'
  gem 'poltergeist'
  gem 'fakeweb'
end
