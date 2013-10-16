# coding: utf-8
lib = File.expand_path('../lib', __FILE__)
$LOAD_PATH.unshift(lib) unless $LOAD_PATH.include?(lib)
require 'hatebu_entry/version'

Gem::Specification.new do |spec|
  spec.name          = "hatebu_entry"
  spec.version       = HatebuEntry::VERSION
  spec.authors       = ["kyoendo"]
  spec.email         = ["postagie@gmail.com"]
  spec.description   = %q{HatebuEntry is a tool for retrieving and handling Hatena Bookmark entry lists written in Ruby.}
  spec.summary       = %q{Hatena bookmark entry list handler}
  spec.homepage      = "https://github.com/melborne/hatebu_entry"
  spec.license       = "MIT"

  spec.files         = `git ls-files`.split($/)
  spec.executables   = spec.files.grep(%r{^bin/}) { |f| File.basename(f) }
  spec.test_files    = spec.files.grep(%r{^(test|spec|features)/})
  spec.require_paths = ["lib"]

  spec.required_ruby_version = '>= 1.9.3'
  spec.add_runtime_dependency 'nokogiri'
  spec.add_runtime_dependency 'thor'
  spec.add_development_dependency "bundler", "~> 1.3"
  spec.add_development_dependency "rake"
  spec.add_development_dependency "rspec"
  spec.add_development_dependency "fakeweb", "~> 1.3"
end
