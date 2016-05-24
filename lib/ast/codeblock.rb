class CodeBlock < BlockElement
  attr_accessor :language
  
  def accept(renderer)
      renderer.visit(self)
  end
end
