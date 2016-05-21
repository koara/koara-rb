class CharStream
  def initialize(reader)
    @available = 4096
    @buf_size = 4096
    @buf_column = Array.new
    @buf_pos = -1
    @buf_line = Array.new
    @column = 0
    @line = 1
    @prev_char_is_lf = false
    @buffer = Array.new
    @max_next_char_ind = 0
    @reader = reader
    @in_buf = 0
    @tab_size = 4
    @token_begin = 0
  end

  def begin_token()
    @token_begin = -1
    c = read_char()
    @token_begin = @buf_pos
    return c
  end

  def read_char()
    if (@in_buf > 0)
      @in_buf -= 1
      if ((@bufpos += 1) == @bufsize)
        @bufpos = 0
      end
      return @buffer[@bufpos]
    end

    if ((@buf_pos += 1) >= @max_next_char_ind)
      fill_buff()
    end
    c = @buffer[@buf_pos]
    update_line_column(c)
    return c
  end

  def fill_buff()
    if (@max_next_char_ind == @available)
      if (@available == @bufsize)
        @buf_pos = 0
        @max_next_char_ind = 0
        if (@token_begin > 2048)
          @available = @token_begin
        else
          @available = @buf_size
        end
      end
    end
    i = 0

    begin
      if ((i = @reader.read(@buffer, @max_next_char_ind, @available - @max_next_char_ind)) == -1)
        raise IOException
      else
        @max_next_char_ind += i
      end
    rescue => e
      @buf_pos -= 1
      backup(0)
      if (@token_begin == -1)
        @token_begin = @buf_pos
      end
      raise e
    end

  end

  def backup(amount)
    @in_buf += amount
    if ((@buf_pos -= amount) < 0)
      @buf_pos += @buf_size
    end
  end

  def update_line_column(c)
    @column += 1

    if (@prev_char_is_lf)
      @prev_char_is_lf = false
      @column = 1
      @line += @column
    end

    case c
    when '\n'
      @prev_char_is_lf = true
    when '\t'
      @column -= 1
      @column += (@tabSize - (@column % @tab_size))
    end

    @buf_line[@buf_pos] = @line
    @buf_column[@buf_pos] = @column
  end

  def get_image()
    if (@buf_pos >= @token_begin)
      return @buffer[@token_begin, (@buf_pos - @token_begin + 1)].join()
    end
    #        return new String(buffer, tokenBegin, bufsize - tokenBegin) + new String(buffer, 0, bufpos + 1)
  end

  def end_column()
    return @buf_column[@buf_pos]
  end

  def end_line()
    return @buf_line[@buf_pos]
  end

  def begin_column()
    return @buf_column[@token_begin]
  end

  def begin_line()
    return @buf_line[@token_begin]
  end

end