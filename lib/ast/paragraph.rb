def Paragraph < BlockElement
  def accept(renderer)
    renderer.visit(this)
  end
end