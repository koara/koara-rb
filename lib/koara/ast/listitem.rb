# encoding: utf-8
require_relative 'blockelement'

module Koara
  module Ast
    class ListItem < BlockElement
      attr_accessor :number

      def accept(renderer)
        renderer.visit_list_item(self)
      end
    end
  end
end