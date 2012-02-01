# -*- encoding: utf-8 -*-
$:.push File.expand_path("../lib", __FILE__)
require "iqvoc/auto_classify/version"

Gem::Specification.new do |s|
  s.name        = "iqvoc_autoclassify"
  s.version     = Iqvoc::AutoClassify::VERSION
  s.platform    = Gem::Platform::RUBY
  s.authors     = ["Robert Glaser", "Frederik Dohr", "Till Schulte-Coerne"]
  s.email       = ["robert.glaser@innoq.com"]
  s.homepage    = "http://innoq.com"
  s.summary     = "automatic classification of documents based on iQvoc thesauri"
  s.description = ""

  s.add_dependency "iqvoc"
  s.add_dependency "iqvoc_skosxl"
  s.add_dependency "iqvoc_inflectionals"
  s.add_dependency "iqvoc_compound_forms"
  s.add_dependency "bundler"
  s.add_dependency "ruby-readability"
  s.add_dependency "pdf-reader", "~> 0.10.0"

  # s.rubyforge_project = "iqvoc_autoclassify"

  s.files         = `git ls-files`.split("\n")
  s.test_files    = `git ls-files -- {test,spec,features}/*`.split("\n")
  s.executables   = `git ls-files -- bin/*`.split("\n").map{ |f| File.basename(f) }
  s.require_paths = ["lib"]
end
