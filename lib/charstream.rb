class CharStream
  def initialize(reader)
    @available = 4096
    @buf_size = 4096
    @buf_column = Array.new(4096,0)
    @buf_pos = -1
    @buf_line = Array.new(4096,0)
    @column = 0
    @line = 1
    @prev_char_is_lf = false
    @buffer = Array.new(4096,'')
    @max_next_char_ind = 0
    @reader = reader
    @in_buf = 0
    @tab_size = 4
    @token_begin = 0
  end

  def begin_token
    @token_begin = -1
    c = read_char
    @token_begin = @buf_pos
    c
  end

  def read_char
    if @in_buf > 0
      @in_buf -= 1
      if (@buf_pos += 1) == @buf_size
        @buf_pos = 0
      end
      return @buffer[@buf_pos]
    end

    if (@buf_pos += 1) >= @max_next_char_ind
      fill_buff
    end
    c = @buffer[@buf_pos]
    update_line_column(c)
    c
  end

  def fill_buff
    if @max_next_char_ind == @available
      if @available == @buf_size
        @buf_pos = 0
        @max_next_char_ind = 0
        if @token_begin > 2048
          @available = @token_begin
        else
          @available = @buf_size
        end
      end
    end
    i = 0

    begin
      if (i = @reader.read(@buffer, @max_next_char_ind, @available - @max_next_char_ind)) == -1
        raise IOError
      else
        @max_next_char_ind += i
      end
    rescue => e
      @buf_pos -= 1
      backup(0)
      if @token_begin == -1
        @token_begin = @buf_pos
      end
      raise e
    end
  end

  def backup(amount)
    @in_buf += amount
    if (@buf_pos -= amount) < 0
      @buf_pos += @buf_size
    end
  end

  def update_line_column(c)
    @column += 1

    if @prev_char_is_lf
      @prev_char_is_lf = false
      @column = 1
      @line += @column
    end

    case c
      when '\n'
        @prev_char_is_lf = true
      when '\t'
        @column -= 1
        @column += (@tab_size - (@column % @tab_size))
    end
    @buf_line[@buf_pos] = @line
    @buf_column[@buf_pos] = @column
  end

  def image
    if @buf_pos >= @token_begin
      return @buffer[@token_begin, @buf_pos - @token_begin + 1].join
    end
    "X"
    #        return new String(buffer, tokenBegin, bufsize - tokenBegin) + new String(buffer, 0, buf_pos + 1)
  end

  def end_column
    @buf_column[@buf_pos]
  end

  def end_line
    @buf_line[@buf_pos]
  end

  def begin_column
    @buf_column[@token_begin]
  end

  def begin_line
    @buf_line[@token_begin]
  end

end