require_relative 'node'

class Strong < Node
  def accept(renderer)
    renderer.visit_strong(self)
  end
end
