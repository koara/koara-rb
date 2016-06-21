# encoding: utf-8
require_relative 'node'

class Link < Node
  def accept(renderer)
    renderer.visit_link(self)
  end
end
