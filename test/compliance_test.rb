require_relative '../lib/parser'
require_relative '../lib/ast/document'
require_relative 'html5renderer'
require "test/unit"
require 'pathname'

class ComplianceTest < Test::Unit::TestCase


  @tests = Dir.glob('/Users/andy/git/koara/testsuite/input/**/*')


  @tests.each do |test|
    path = Pathname.new(test)
    folder =  File.expand_path("..", path).split('/')[-1].to_s
    testcase = path.basename.to_s[0..-4]

    define_method("test_#{testcase}") do
      kd = File.read("/Users/andy/git/koara/testsuite/input/#{folder}/#{testcase}.kd")
      html = File.read("/Users/andy/git/koara/testsuite/output/html5/#{folder}/#{testcase}.htm")

      parser = Parser.new
      document = parser.parse(kd)
      renderer = Html5Renderer.new
      document.accept(renderer)
      assert_equal(html, renderer.output)
    end
  end
end