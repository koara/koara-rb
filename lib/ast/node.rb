class Node
  def initialize(name)
    @children = Array.new
  end

  def add(n, i)
    @children[i] = n
  end

  def childrenAccept(renderer)
    @children[]

    i = 0
    while(i < @children.length)
      @children[i].accept(renderer);
      i += 1
    end

  end

end
