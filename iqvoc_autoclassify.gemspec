# -*- encoding: utf-8 -*-
$:.push File.expand_path('../lib', __FILE__)
require 'iqvoc/auto_classify/version'

Gem::Specification.new do |s|
  s.name        = 'iqvoc_autoclassify'
  s.version     = Iqvoc::AutoClassify::VERSION
  s.platform    = Gem::Platform::RUBY
  s.required_ruby_version = '>= 3.3'
  s.authors     = ['Robert Glaser', 'Frederik Dohr', 'Till Schulte-Coerne']
  s.email       = ['robert.glaser@innoq.com']
  s.homepage    = 'https://github.com/innoq/iqvoc_autoclassify'
  s.license     = 'Apache-2.0'
  s.summary     = 'Automatic classification of documents based on iQvoc thesauri'
  s.description = 'Automatic classification of documents based on iQvoc thesauri'

  s.add_dependency 'iqvoc', '~> 4.17.0'
  s.add_dependency 'iqvoc_skosxl', '~> 2.13.0'
  s.add_dependency 'iqvoc_inflectionals', '~> 2.13.0'
  s.add_dependency 'iqvoc_compound_forms', '~> 2.13.0'
  s.add_dependency 'ruby-readability'
  s.add_dependency 'pdf-reader', '~> 2.16.0'
  s.add_dependency 'workflow', '~> 1.0.0'
  s.add_dependency 'guess_html_encoding'
  s.add_dependency 'responders'
  s.add_dependency 'pragmatic_segmenter'

  s.files         = `git ls-files -z -- README.md LICENSE Gemfile Rakefile iqvoc_autoclassify.gemspec app config db lib test`.split("\0")
  s.test_files    = s.files.grep(%r{^test/})
  s.require_paths = ['lib']
end
