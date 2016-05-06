def CodeBlock < BlockElement
  attr_accessor :language
  
  def accept(renderer)
      renderer.visit(this)
  end
end
