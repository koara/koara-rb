# -*- encoding: utf-8 -*-
lib = File.expand_path("../lib", __FILE__)
$LOAD_PATH.unshift(lib) unless $LOAD_PATH.include?(lib)

Gem::Specification.new do |gem|
  gem.name          = "koara"
  gem.version       = "0.9.0"
  gem.authors       = ["Andy VAn Den Heuvel"]
  gem.email         = ["andy.vandenheuvel@gmail.com"]
  gem.description   = "Koara parser written in Ruby"
  gem.summary       = "Koara parser written in Ruby"
  gem.homepage      = "https://github.com/koara/koara-rb"
  gem.license       = "Apache 2.0"

  gem.files         = `git ls-files`.split($/)
  gem.test_files    = gem.files.grep(%r{^(test|spec|features)/})
  gem.require_paths = ["lib"]
end
