require_relative 'blockelement'

class ListBlock < BlockElement
  attr_accessor :ordered
  
  def initialize(ordered)
    @ordered = ordered
  end
  
  def accept(renderer)
    renderer.visit(self)
  end
end