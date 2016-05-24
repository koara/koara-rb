class ListItem < BlockElement
  attr_accessor :number
  
  def accept(renderer)
    renderer.visit(self)
  end
end