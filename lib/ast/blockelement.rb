require_relative 'node'

class BlockElement < Node
  
  def has_children
    self.children && self.children.length > 0
  end
  
  def is_first_child
    parent.children[0] == self
  end
  
  def is_last_child
    parent.children.last == self
  end
  
  def nested
    !parent.instance_of? Document
  end
  
  def is_single_child
    parent.children.length == 1
  end
  
  def next
    #     for(int i = 0 i < getParent().getChildren().length - 1 i++) {
    #       if(getParent().getChildren()[i] == this) {
    #         return getParent().getChildren()[i + 1]
    #       }
    #     }
    #     return null
  end
  
  def accept(renderer)
    renderer.visit(this)
  end
  
end