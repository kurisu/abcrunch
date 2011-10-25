# -*- encoding: utf-8 -*-
$:.push File.expand_path("../lib", __FILE__)
require "abcrunch/version"

Gem::Specification.new do |s|
  s.name        = "abcrunch"
  s.version     = AbCrunch::VERSION
  s.authors     = ["Chris Lichti"]
  s.email       = ["kai@truecar.com"]
  s.homepage    = "https://github.com/kurisu/abcrunch"
  s.summary     = "Automated load testing in ruby"
  s.description = <<-DESC
The idea behind Ab Crunch is that basic performance metrics and standards should
be effortless, first-class citizens in the development process, with frequent visibility
and immediate feedback when performance issues are introduced.

Ab Crunch uses Apache Bench to run various strategies for load testing web projects,
and provides rake tasks for analyzing performance and enforcing performance
standards on CI.
DESC

  s.rubyforge_project = "abcrunch"

  s.files         = `git ls-files`.split("\n")
  s.test_files    = `git ls-files -- {test,spec,features}/*`.split("\n")
  s.executables   = `git ls-files -- bin/*`.split("\n").map{ |f| File.basename(f) }
  s.require_paths = ["lib"]

  s.add_runtime_dependency "rspec"
  s.add_runtime_dependency "rr"
  s.add_runtime_dependency "colorize"

  # specify any dependencies here; for example:
  # s.add_development_dependency "rspec"
  # s.add_runtime_dependency "rest-client"
end
