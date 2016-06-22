# encoding: utf-8
require_relative 'node'

module Koara
  module Ast
    class Em < Node
      def accept(renderer)
        renderer.visit_em(self)
      end
    end
  end
end