# encoding: utf-8
require_relative 'heading'

module Koara
  module Ast
    class Heading < BlockElement
      def accept(renderer)
        renderer.visit_heading(self)
      end
    end
  end
end