# -*- encoding: utf-8 -*-
$:.push File.expand_path("../lib", __FILE__)
require "watir-webdriver/version"

Gem::Specification.new do |s|
  s.name                    = "watir-webdriver"
  s.version                 = Watir::VERSION
  s.platform                = Gem::Platform::RUBY
  s.authors                 = ['Aaron Humerickhouse']
  s.email                   = ['a.humerickhouse@sportngin.com']
  s.homepage                = "http://github.com/sportngin/watir-webdriver"
  s.summary                 = %q{Watir on WebDriver}
  s.description             = %q{WebDriver-backed Watir}
  s.license                 = 'MIT'
  s.required_ruby_version   = '~> 1.9.3'

  s.files                   = `git ls-files`.split("\n")
  s.test_files              = `git ls-files -- {test,spec,features}/*`.split("\n")
  s.executables             = `git ls-files -- bin/*`.split("\n").map{ |f| File.basename(f) }
  s.require_paths           = ["lib"]

  s.add_dependency "selenium-webdriver", '>= 2.44'

  s.add_development_dependency "rspec", "~> 2.6"
  s.add_development_dependency "yard", "~> 0.8.2.1"
  s.add_development_dependency "webidl", ">= 0.1.5"
  s.add_development_dependency "sinatra", "~> 1.0"
  s.add_development_dependency "rake", "~> 0.9.2"
  s.add_development_dependency "fuubar"
  s.add_development_dependency "nokogiri"
  s.add_development_dependency "activesupport", "~> 3.0" # for pluralization during code generation
  s.add_development_dependency "pry"
  s.add_development_dependency "coveralls"
  s.add_development_dependency "yard-doctest", "0.1.4"
end
