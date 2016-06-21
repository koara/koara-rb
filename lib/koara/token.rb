class Token
  attr_accessor :kind
  attr_accessor :begin_line
  attr_accessor :begin_column
  attr_accessor :end_line
  attr_accessor :end_column
  attr_accessor :image
  attr_accessor :next
  
  def initialize(kind = 0, begin_line = nil, begin_column = nil, end_line = nil, end_column = nil, image = nil)
    @kind = kind
    @begin_line = begin_line
    @begin_column = begin_column
    @end_line = end_line
    @end_column =  end_column
    @image = image
  end

end