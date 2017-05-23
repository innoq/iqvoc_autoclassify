# -*- encoding: utf-8 -*-
$:.push File.expand_path('../lib', __FILE__)
require 'iqvoc/auto_classify/version'

Gem::Specification.new do |s|
  s.name        = 'iqvoc_autoclassify'
  s.version     = Iqvoc::AutoClassify::VERSION
  s.platform    = Gem::Platform::RUBY
  s.authors     = ['Robert Glaser', 'Frederik Dohr', 'Till Schulte-Coerne']
  s.email       = ['robert.glaser@innoq.com']
  s.homepage    = 'http://iqvoc.net'
  s.summary     = 'Automatic classification of documents based on iQvoc thesauri'
  s.description = 'Automatic classification of documents based on iQvoc thesauri'

  s.add_dependency 'iqvoc', '>= 4.5.0', '~> 4.11'
  s.add_dependency 'iqvoc_skosxl', '~> 2.9.0'
  s.add_dependency 'iqvoc_inflectionals', '~> 2.9.0'
  s.add_dependency 'iqvoc_compound_forms', '~> 2.9.0'
  s.add_dependency 'bundler'
  s.add_dependency 'ruby-readability'
  s.add_dependency 'pdf-reader', '~> 1.4.0'
  s.add_dependency 'workflow', '~> 1.0.0'
  s.add_dependency 'guess_html_encoding'
  s.add_dependency 'nokogiri'
  s.add_dependency 'responders', '~> 2.0'
  s.add_dependency 'pragmatic_segmenter', '~> 0.3.7'
  s.add_dependency 'ffi', '~> 1.9.10'

  # s.rubyforge_project = "iqvoc_autoclassify"

  s.files         = `git ls-files`.split("\n")
  s.test_files    = `git ls-files -- {test,spec,features}/*`.split("\n")
  s.require_paths = ['lib']
end
