require_relative 'node'

class Document < Node
  def accept(renderer)
    renderer.visit(self)
  end

end