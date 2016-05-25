require_relative 'node'

class Text < Node
  def accept(renderer)
    renderer.visit_text(self)
  end
end
