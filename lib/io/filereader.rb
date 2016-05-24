class FileReader
  def initialize(file_name)
    @text = File.read(file_name)
    @index=0
  end

  def read(buffer, offset, length)
    slice = @text.slice(@index, @text.length)

    if @text != '' && slice && slice.length > 0
      characters_read = 0
      0.upto(length - 1) do |i|
        c = @text.slice(@index + i)
        if c
          buffer[offset + i] = c
          characters_read += 1
        end
      end
      @index += length
      return characters_read
    end
    -1
  end

end