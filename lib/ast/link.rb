require_relative 'node'

class Link < Node
  def accept(renderer)
    renderer.visit(self)
  end
end
