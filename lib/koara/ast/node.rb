# encoding: utf-8
require_relative 'node'

class Node
  attr_accessor :parent
  attr_accessor :value
  attr_accessor :children

  def add(n, i)
    if@children.nil?
      @children = Array.new
    end
    @children[i] = n
  end

  def children_accept(renderer)
    if !@children.nil?
      i = 0
      while i < @children.length
        @children[i].accept(renderer)
        i += 1
      end
    end
  end

end
