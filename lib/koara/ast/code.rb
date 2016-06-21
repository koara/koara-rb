# encoding: utf-8
require_relative 'node'

class Code < Node
  def accept(renderer)
    renderer.visit_code(self)
  end
end
