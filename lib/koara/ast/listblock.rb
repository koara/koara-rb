# encoding: utf-8
require_relative 'blockelement'

module Koara
  module Ast
    class ListBlock < BlockElement
      attr_accessor :ordered

      def initialize(ordered)
        @ordered = ordered
      end

      def accept(renderer)
        renderer.visit_list_block(self)
      end
    end
  end
end