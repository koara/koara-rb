class StringReader
  def initialize(text='')
    @text = text
    @index = 0
  end

  def read(buffer, offset, length)
    slice = @text.slice(@index, @text.length)

    if @text != '' && slice && slice.length > 0
      characters_read = 0
      i = 0
      while(i < length)
        c = @text.slice(@index + i)
        if c
          buffer[offset + i] = c;
          characters_read += 1
        end
        i += 1
      end
      @index += length
      return characters_read
    end
    -1
  end

end