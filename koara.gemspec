# encoding: utf-8

$: << File.expand_path('../lib', __FILE__)
require 'koara/version'

Gem::Specification.new do |s|
  s.name         = 'koara'
  s.version      = Koara::VERSION
  s.authors      = ['Andy Van Den Heuvel']
  s.email        = 'andy.vandenheuvel@gmail.com'
  s.homepage     = 'http://github.com/koara/koara-rb'
  s.summary      = 'Koara parser written in Ruby'
  s.description  = 'Koara parser written in Ruby'
  s.license      = 'Apache-2.0'

  s.files        = Dir.glob("{gemfiles,lib,test}/**/**") + %w(README.md LICENSE)
  s.platform     = Gem::Platform::RUBY
  s.require_path = 'lib'
  s.required_rubygems_version = '>= 1.3.5'
  s.required_ruby_version = '>= 1.9.3'
end