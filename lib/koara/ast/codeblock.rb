# encoding: utf-8
require_relative 'blockelement'

class CodeBlock < BlockElement
  attr_accessor :language
  
  def accept(renderer)
      renderer.visit_codeblock(self)
  end
end
