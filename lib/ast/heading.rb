def Heading
  def accept(renderer)
    renderer.visit(this)
  end
end