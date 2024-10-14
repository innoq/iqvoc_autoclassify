source 'https://rubygems.org'

gem 'iqvoc', '~> 4.14.4', :github => 'innoq/iqvoc', branch: :main
gem 'iqvoc_skosxl', '~> 2.11.3', :github => 'innoq/iqvoc_skosxl', branch: :main
gem 'iqvoc_inflectionals', '~> 2.11.3', :github => 'innoq/iqvoc_inflectionals', branch: :main
gem 'iqvoc_compound_forms', '~> 2.11.3', :github => 'innoq/iqvoc_compound_forms', branch: :main

gem 'ruby-readability'
gem 'pdf-reader', '~> 1.4.0'
gem 'workflow', '~> 1.0.0'
gem 'guess_html_encoding'
gem 'responders'
gem 'pragmatic_segmenter', '~> 0.3.23', :github => 'innoq/pragmatic_segmenter', branch: 'issue-78'

platforms :ruby do
  gem 'pg'
end

group :development do
  gem 'web-console'
  gem 'listen'
end

group :development, :test do
  # See https://guides.rubyonrails.org/debugging_rails_applications.html#debugging-with-the-debug-gem
  gem "debug", platforms: %i[ mri mingw x64_mingw ]
end

group :test do
  gem 'rails-controller-testing'
  gem 'capybara'
  gem 'poltergeist'
  gem 'webmock'
end
