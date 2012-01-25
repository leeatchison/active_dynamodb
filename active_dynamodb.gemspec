# -*- encoding: utf-8 -*-
$:.push File.expand_path("../lib", __FILE__)
require "active_dynamodb/version"

Gem::Specification.new do |s|
  s.name        = "active_dynamodb"
  s.version     = ActiveDynamoDB::VERSION
  s.authors     = ["Lee Atchison"]
  s.email       = ["lee@leeatchison.com"]
  s.homepage    = ""
  s.summary     = %q{Rails ORM for Amazon's DynamoDB. This is ALPHA quality code currently. Please see readme on GitHub.}
  s.description = %q{Rails ORM for Amazon's DynamoDB. This is ALPHA quality code currently. Please see readme on GitHub.}

  s.rubyforge_project = "active_dynamodb"

  s.files         = `git ls-files`.split("\n")
  s.test_files    = `git ls-files -- {test,spec,features}/*`.split("\n")
  s.executables   = `git ls-files -- bin/*`.split("\n").map{ |f| File.basename(f) }
  s.require_paths = ["lib"]

  # specify any dependencies here; for example:
  s.add_development_dependency "rspec"
  s.add_runtime_dependency "activemodel"
  s.add_runtime_dependency "aws-sdk"
end
