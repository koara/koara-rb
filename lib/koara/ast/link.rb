# encoding: utf-8
require_relative 'node'

module Koara
  module Ast
    class Link < Node
      def accept(renderer)
        renderer.visit_link(self)
      end
    end
  end
end