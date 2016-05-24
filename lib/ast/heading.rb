class Heading < BlockElement
  def accept(renderer)
    renderer.visit(self)
  end
end