# encoding: utf-8
module Koara
  class TreeState
    def initialize
      @nodes = []
      @marks = []
      @nodes_on_stack = 0
      @current_mark = 0
    end

    def open_scope
      @marks.push(@current_mark)
      @current_mark = @nodes_on_stack
    end

    def close_scope(n)
      a = node_arity
      @current_mark = @marks.delete_at(@marks.size - 1)
      while a > 0
        a -= 1
        c = pop_node
        c.parent = n
        n.add(c, a)
      end
      push_node(n)
    end

    def add_single_value(n, t)
      open_scope
      n.value = t.image
      close_scope(n)
    end

    def node_arity
      @nodes_on_stack - @current_mark
    end

    def pop_node
      @nodes_on_stack -= 1
      @nodes.delete_at(@nodes.size - 1)
    end

    def push_node(n)
      @nodes.push(n)
      @nodes_on_stack += 1
    end
  end
end