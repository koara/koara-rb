class BlockElement < Node
  
  def hasChildren
    self.children && self.children.length > 0
  end
  
  def isFirstChild
   # return getParent().getChildren()[0] == this;
  end
  
  def isLastChild
    #   Node[] children = getParent().getChildren();
    #   return children[children.length - 1] == this;
  end
  
  def isNested
    #        return !(getParent() instanceof Document);
  end
  
  def isSingleChild
    #        return ((Node) this.getParent()).getChildren().length == 1;
  end
  
  def next
    #     for(int i = 0; i < getParent().getChildren().length - 1; i++) {
    #       if(getParent().getChildren()[i] == this) {
    #         return getParent().getChildren()[i + 1];
    #       }
    #     }
    #     return null;
  end
  
  def accept(renderer)
    renderer.visit(this)
  end
  
end