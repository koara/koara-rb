require_relative 'blockelement'

class BlockQuote < BlockElement
  def accept(renderer)
    renderer.visit_blockquote(self)
  end
end
