require_relative 'node'

class Em < Node
  def accept(renderer)
    renderer.visit_em(self)
  end
end
