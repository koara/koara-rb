require_relative 'blockelement'

class ListItem < BlockElement
  attr_accessor :number
  
  def accept(renderer)
    renderer.visit_list_item(self)
  end
end