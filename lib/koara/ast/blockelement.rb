# encoding: utf-8
require_relative 'node'

module Koara
  module Ast
    class BlockElement < Node

      def has_children
        self.children && self.children.length > 0
      end

      def is_first_child
        parent.children[0] == self
      end

      def is_last_child
        parent.children.last == self
      end

      def nested
        !parent.instance_of? Document
      end

      def is_single_child
        parent.children.length == 1
      end

      def next
        i = 0
        while (i < parent.children.length - 1)
          if (parent.children[i] == self)
            return parent.children[i + 1]
          end
          i+=1
        end
        return nil
      end

      def accept(renderer)
        renderer.visit_block_element(self)
      end

    end
  end
end