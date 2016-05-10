require_relative '../lib/parser'
require_relative '../lib/ast/document'
require_relative 'html5renderer'
require "test/unit"

class ComplianceTest < Test::Unit::TestCase

  def test_koara_to_html5
    kd = File.read('/Users/andy/git/koara/testsuite/input/paragraphs/paragraphs-001-simple.kd')
    html = File.read('/Users/andy/git/koara/testsuite/output/html5/paragraphs/paragraphs-001-simple.htm')
   
    parser = Parser.new
    document = parser.parse(kd)
    renderer = Html5Renderer.new
    document.accept(renderer)
    assert_equal(html, renderer.getOutput())
  end


end