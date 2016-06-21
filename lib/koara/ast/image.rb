require_relative 'node'

class Image < Node
  def accept(renderer)
      renderer.visit_image(self)
  end
end