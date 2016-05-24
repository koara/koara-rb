require_relative 'node'

class Em < Node
  def accept(renderer)
    renderer.visit(self)
  end
end
