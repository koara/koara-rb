require_relative 'node'

class Image < Node
  def accept(renderer)
      renderer.visit(self)
  end
end