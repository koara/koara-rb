# encoding: utf-8
require_relative 'blockelement'

module Koara
  module Ast
    class BlockQuote < BlockElement
      def accept(renderer)
        renderer.visit_blockquote(self)
      end
    end
  end
end