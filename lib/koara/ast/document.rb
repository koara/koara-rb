# encoding: utf-8
require_relative 'node'

module Koara
  module Ast
    class Document < Node
      def accept(renderer)
        renderer.visit_document(self)
      end
    end
  end
end