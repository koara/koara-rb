require_relative 'linebreak'

class LineBreak < Node
  def accept(renderer)
    renderer.visit(self)
  end
end