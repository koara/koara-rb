require_relative 'blockelement'

class Paragraph < BlockElement
  def accept(renderer)
    renderer.visit_paragraph(self)
  end
end