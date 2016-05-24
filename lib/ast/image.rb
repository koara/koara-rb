class Image < Node
  def accept(renderer)
      renderer.visit(self)
  end
end