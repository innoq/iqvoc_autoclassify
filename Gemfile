source 'https://rubygems.org'

gem 'iqvoc', '~> 4.4.0', :github => 'innoq/iqvoc'
gem 'iqvoc_skosxl', '~> 2.4.0', :github => 'innoq/iqvoc_skosxl'
gem 'iqvoc_inflectionals', '~> 2.4.0', :github => 'innoq/iqvoc_inflectionals'
gem 'iqvoc_compound_forms', '~> 2.4.0', :github => 'innoq/iqvoc_compound_forms'

gem 'ruby-readability', :require => 'readability'
gem 'nokogiri', '~> 1.5.0'
gem 'pdf-reader', '~> 0.10.0'
gem 'workflow', '~> 1.0.0'
gem 'guess_html_encoding'

group :development, :test do
  gem 'awesome_print'
  gem 'spring'
  gem 'pry'
  gem 'pry-rails'
  gem 'pry-remote'

  platforms :ruby do
    gem 'mysql2'
    gem 'sqlite3'

    gem 'hirb-unicode'
    gem 'cane'
  end
end

group :test do
  gem 'capybara', '~> 1.1.2'
  gem 'database_cleaner'
  gem 'fakeweb'
end
