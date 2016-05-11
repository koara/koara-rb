class CharStream
  def initialize(reader)
    @available = 4096
    @bufsize = 4096
    @bufcolumn = Array.new
    @bufpos = -1
    @bufline = Array.new
    @column = 0
    @line = 1
    @prev_char_is_lf = false
    @buffer = Array.new
    @max_next_char_ind = 0
    @reader = reader
    @inBuf = 0
    @tabSize = 4
  end

  def beginToken()
    @tokenBegin = -1
    c = readChar()
    tokenBegin = @bufpos
    return c
  end

  def readChar()
    if (@inBuf > 0)
      @inBuf -= 1
      if ((@bufpos += 1) == @bufsize)
        @bufpos = 0
      end
      return @buffer[@bufpos]
    end
    
    if ((@bufpos += 1) >= @max_next_char_ind)
      fillBuff()
    end
    c = @buffer[@bufpos]
    updateLineColumn(c)
    return c
  end

  def fillBuff()
    if (@maxNextCharInd == @available)
      if (@available == @bufsize)
        @bufpos = 0
        @maxNextCharInd = 0
        if (@tokenBegin > 2048)
          @available = @tokenBegin
        else
          @available = @bufsize
        end
      end
    end
    i = 0
    
    xbuffer = ""
    @reader.read(5, xbuffer)
    
    puts "////" + xbuffer
    

    #        try {
    #            if ((i = reader.read(buffer, maxNextCharInd, available - maxNextCharInd)) == -1) {
    #              reader.close()
    #                throw new IOException()
    #            } else {
    #                maxNextCharInd += i
    #            }
    #        } catch (IOException e) {
    #            --bufpos
    #            backup(0)
    #            if (tokenBegin == -1) {
    #                tokenBegin = bufpos
    #            }
    #            throw e
    #        }
  end

  def backup(amount)
    @inBuf += amount
    if ((bufpos -= amount) < 0)
      @bufpos += @bufsize
    end
  end

  def updateLineColumn(c)
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
        @column += (@tabSize - (@column % @tabSize)) 
    end
    
    @bufline[@bufpos] = @line
    @bufcolumn[@bufpos] = @column
  end

  def getImage()
    if (bufpos >= tokenBegin)
      #            return new String(buffer, tokenBegin, bufpos - tokenBegin + 1)
    end
    #        return new String(buffer, tokenBegin, bufsize - tokenBegin) + new String(buffer, 0, bufpos + 1)
  end

  def getEndColumn()
    return @bufcolumn[@bufpos]
  end

  def getEndLine()
    return @bufline[@bufpos]
  end

  def getBeginColumn()
    return @bufcolumn[@tokenBegin]
  end

  def getBeginLine()
    return @bufline[@tokenBegin]
  end

end