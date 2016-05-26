require_relative '../lib/parser'
require_relative '../lib/ast/document'
require_relative 'html5renderer'
require "test/unit"
require 'pathname'

class ComplianceTest < Test::Unit::TestCase


  @tests = Dir.glob('/Users/andy/git/koara/testsuite/input/**/*')


  @tests.each do |test|
    define_method("test_#{test}") do


      puts "//" + Pathname.new(test).basename
      #kd = File.read("/Users/andy/git/koara/testsuite/input/paragraphs/#{test}.kd")
      #html = File.read("/Users/andy/git/koara/testsuite/output/html5/paragraphs/#{test}.htm")

      #parser = Parser.new
      #document = parser.parse(kd)
      #renderer = Html5Renderer.new
      #document.accept(renderer)
      #assert_equal(html, renderer.output)
    end
  end
end