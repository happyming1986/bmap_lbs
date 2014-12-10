# coding: utf-8
lib = File.expand_path('../lib', __FILE__)
$LOAD_PATH.unshift(lib) unless $LOAD_PATH.include?(lib)
require 'bmap_lbs/version'

Gem::Specification.new do |spec|
  spec.name          = "bmap_lbs"
  spec.version       = BmapLbs::VERSION
  spec.authors       = ["happyMing"]
  spec.email         = ["339755551@qq.com"]
  spec.summary       = %q{use to communicate with baidu lbs database.}
  spec.description   = %q{a encapsulation about  .}
  spec.homepage      = ""
  spec.license       = "MIT"

  spec.files         = `git ls-files -z`.split("\x0")
  spec.executables   = spec.files.grep(%r{^bin/}) { |f| File.basename(f) }
  spec.test_files    = spec.files.grep(%r{^(test|spec|features)/})
  spec.require_paths = ["lib"]

  spec.add_development_dependency "bundler", "~> 1.5"
  spec.add_development_dependency "rake"
end
