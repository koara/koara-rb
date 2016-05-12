class Token
  attr_accessor :kind
  attr_accessor :begin_line
  attr_accessor :begin_column
  attr_accessor :end_line
  attr_accessor :end_column
  attr_accessor :image
  attr_accessor :next
  
  def initiliaze()
  end
  
  def initiliaze(kind, begin_line, begin_column, end_line, end_column, image)
    @kind = kind
    @begin_line = begin_line
    @begin_column = begin_column
    @end_line = end_line
    @end_column =  end_column
    @image = image
  end

end