require_relative 'blockelement'

class Paragraph < BlockElement
  def accept(renderer)
    renderer.visit(self)
  end
end