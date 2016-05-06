def LineBreak < Node
  def accept(renderer)
    renderer.visit(this)
  end
end