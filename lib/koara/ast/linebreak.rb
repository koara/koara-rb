require_relative 'linebreak'

class LineBreak < Node
  def accept(renderer)
    renderer.visit_linebreak(self)
  end
end