# -*- encoding: utf-8 -*-
$:.push File.expand_path("../lib", __FILE__)
require "dot_mailer/version"

Gem::Specification.new do |s|
  s.name        = "dotmailer"
  s.version     = DotMailer::VERSION
  s.authors     = ["Econsultancy"]
  s.email       = ["tech@econsultancy.com"]
  s.homepage    = "https://github.com/econsultancy/dotmailer"
  s.summary     = %q{A Ruby wrapper around the dotMailer REST API: https://apiconnector.com/v2/help/wadl}
  s.license     = 'MIT'

  s.rubyforge_project = "dotmailer"

  s.files         = `git ls-files`.split("\n")
  s.test_files    = `git ls-files -- {spec}/*`.split("\n")
  s.executables   = `git ls-files -- bin/*`.split("\n").map{ |f| File.basename(f) }
  s.require_paths = ["lib"]

  s.add_runtime_dependency 'activesupport'
  s.add_runtime_dependency 'rest-client'

  s.add_development_dependency 'rspec'
  s.add_development_dependency 'webmock'
  s.add_development_dependency 'pry'
  s.add_development_dependency 'rspec-its'
end
