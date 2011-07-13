# -*- encoding: utf-8 -*-
$:.push File.expand_path("../lib", __FILE__)
require "iqvoc/auto_classify/version"

Gem::Specification.new do |s|
  s.name        = "iqvoc_autoclassify"
  s.version     = Iqvoc::AutoClassify::VERSION
  s.authors     = ["Robert Glaser", "Frederik Dohr", "Till Schulte-Coerne"]
  s.email       = ["robert.glaser@innoq.com"]
  s.homepage    = ""
  s.summary     = %q{TODO: Write a gem summary}
  s.description = %q{TODO: Write a gem description}

  s.rubyforge_project = "iqvoc_autoclassify"

  s.files         = `git ls-files`.split("\n")
  s.test_files    = `git ls-files -- {test,spec,features}/*`.split("\n")
  s.executables   = `git ls-files -- bin/*`.split("\n").map{ |f| File.basename(f) }
  s.require_paths = ["lib"]
end
