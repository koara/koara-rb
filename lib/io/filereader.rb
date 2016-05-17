require 'active_support/core_ext/string'

class FileReader
  def initialize(file_name)
    @file_name = file_name
    @index=0
  end

  def read(buffer, offset, length)
    filecontent = File.read(@file_name, length * 4, @index)
    puts "////#{filecontent}"
    
    if (filecontent && filecontent.mb_chars != '?')
      characters_read = 0
      0.upto(length - 1) do |i|
        c = filecontent.mb_chars[i].to_s
        if c && c != ''
          buffer[offset + i] = c
          characters_read += 1
        end
      end
      @index +=  filecontent.length
      return characters_read
    end
    return -1
  end

end