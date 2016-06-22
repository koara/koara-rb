# encoding: utf-8
require_relative 'blockelement'

module Koara
  module Ast
    class Paragraph < BlockElement
      def accept(renderer)
        renderer.visit_paragraph(self)
      end
    end
  end
end