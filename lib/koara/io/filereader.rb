# encoding: utf-8
module Koara
  module Io
    class FileReader
      def initialize(file_name)
        @file_name = file_name
        @index = 0
      end

      def read(buffer, offset, length)
        characters_read = 0
        file_content = File.read(@file_name, length * 4, @index)
        if file_content && file_content != ''
          file_content.force_encoding('UTF-8').each_char.with_index { |c, i|
            buffer[offset + i] = c
            characters_read += 1
            @index += c.bytesize
            return characters_read if characters_read >= length
          }
          return characters_read

        end
        -1
      end
    end
  end
end