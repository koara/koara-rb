# encoding: utf-8
require_relative 'node'

module Koara
  module Ast
    class Image < Node
      def accept(renderer)
        renderer.visit_image(self)
      end
    end
  end
end
