# encoding: utf-8
require_relative 'heading'

class Heading < BlockElement
  def accept(renderer)
    renderer.visit_heading(self)
  end

end