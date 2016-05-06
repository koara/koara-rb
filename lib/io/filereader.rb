class FileReader
  def initialize(file_name)
    @file_name = file_name
    @index=0
  end

  def read(buffer, offset, length)
    f = File.open(@file_name,'r:UTF-8')
    
    filecontent = f.read(2)
    puts "///#{filecontent}"
    f.close
    
    puts "///" + filecontent
    
    if filecontent && filecontent.length
      characters_read = 0
      i = 0
      while(i < length)
        c = filecontent.slice(i)
        if c
          buffer[offset + i] = c;
          @index += 1
          characters_read += 1
        end
        i += 1
      end
      return characters_read
    end
    return -1
  end

  #      public function read(&$buffer, $offset, $length) {
  #        $filecontent = @file_get_contents($this->fileName, false, null, $this->index, $length * 4);
  #
  #
  #        if ($filecontent !== false && mb_strlen($filecontent) > 0) {
  #          $charactersRead=0;
  #          for($i=0; $i < $length; $i++) {
  #            $c = mb_substr($filecontent, $i, 1, 'utf-8');
  #            if($c != NULL) {
  #              $buffer[$offset + $i] = $c;
  #              $this->index += strlen($c);
  #              $charactersRead++;
  #            }
  #          }
  #          return $charactersRead;
  #        }
  #        return -1;
  #      }

end