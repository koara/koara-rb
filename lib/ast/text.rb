class Text < Node
  def accept(renderer)
    renderer.visit(self)
  end
end
