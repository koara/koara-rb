# encoding: utf-8
require_relative 'node'

module Koara
  module Ast
    class Code < Node
      def accept(renderer)
        renderer.visit_code(self)
      end
    end
  end
end