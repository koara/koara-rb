class StringReader
  
  def initialize(text='')
    @text = text
    @index = 0
  end
  
  def read(buffer, offset, length) 
    if @text != '' && @text.slice(@index, @text.length).length > 0
      charactersRead = 0
      puts "TEXT!" 
      
      i = 0
      while(i < length)
        c = @text.slice(@index + i)
        if c
          buffer[offset + i] = c;
          charactersRead += 1
        end
        i += 1
      end
      @index += length
      return charactersRead
    end
    -1
  end
  
#    public function read(&$buffer, $offset, $length) {
#      if ($this->text !== false && mb_strlen(mb_substr($this->text, $this->index)) > 0) {
#        $charactersRead=0;
#        for($i=0; $i < $length; $i++) {
#          $c = mb_substr($this->text, $this->index + $i, 1, "utf-8");
#          if($c != NULL) {
#            $buffer[$offset + $i] = $c;
#            $charactersRead++;
#          }
#        }
#        $this->index += $length;
#        return $charactersRead;
#      }
#      return -1;
#    }
  
end