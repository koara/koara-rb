# encoding: utf-8
require_relative 'node'

module Koara
  module Ast
    class Strong < Node
      def accept(renderer)
        renderer.visit_strong(self)
      end
    end
  end
end