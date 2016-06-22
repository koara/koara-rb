# encoding: utf-8
require_relative 'node'

module Koara
  module Ast
    class Text < Node
      def accept(renderer)
        renderer.visit_text(self)
      end
    end
  end
end