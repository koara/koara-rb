# encoding: utf-8
require_relative 'node'

class Document < Node
  def accept(renderer)
    renderer.visit_document(self)
  end

end