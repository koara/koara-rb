# encoding: utf-8
require_relative 'linebreak'

module Koara
  module Ast
    class LineBreak < Node
      def accept(renderer)
        renderer.visit_linebreak(self)
      end
    end
  end
end