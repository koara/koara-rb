def ListItem < BlockElement
  attr_accessor :number
  
  def accept(renderer)
    renderer.visit(this)
  end
end