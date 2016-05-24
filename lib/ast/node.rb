require_relative 'node'

class Node
  attr_accessor :parent
  attr_accessor :value

  def initialize
    @children = Array.new
  end

  def add(n, i)
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
