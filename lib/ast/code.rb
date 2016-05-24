class Code < Node
  def accept(renderer)
    renderer.visit(self)
  end
end
