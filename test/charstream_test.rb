require_relative '../lib/charstream'
require "test/unit"
require "stringio"

class CharStreamTest < Test::Unit::TestCase
  

  def test_begin_token
    cs = CharStream.new(StringIO.new("abcd"))
    
    #      $this->cs = new CharStre am(new StringReader('abcd'))
    assert_equal('a', cs.beginToken())
    assert_equal(1, cs.getBeginColumn())
    assert_equal(1, cs.getBeginLine())
    assert_equal(1, cs.getEndColumn())
    assert_equal(1, cs.getEndLine())
  end
     
  def test_read_char
#      $this->cs = new CharStream(new StringReader('abcd'))
#      $this->assertEquals('a', $this->cs->readChar())
#      $this->assertEquals('b', $this->cs->readChar())
#      $this->assertEquals('c', $this->cs->readChar())
#      $this->assertEquals('d', $this->cs->readChar())
  end
   
#    /**
#     * @expectedException Exception
#     */
  def test_read_char_till_eof
#      $this->cs = new CharStream(new StringReader('abcd'))
#      $this->cs->readChar()
#      $this->cs->readChar()
#      $this->cs->readChar()
#      $this->cs->readChar()
#      $this->cs->readChar()
  end
   
  def test_get_image
#      $this->cs = new CharStream(new StringReader('abcd'))
#      $this->cs->readChar()
#      $this->cs->readChar()
#      $this->assertEquals("ab", $this->cs->getImage())
  end

  def test_begin_token_with_unicode
#      $this->cs = new CharStream(new StringReader('ðinæ'))
#      $this->assertEquals('ð', $this->cs->beginToken())
#      $this->assertEquals(1, $this->cs->getBeginColumn())
#      $this->assertEquals(1, $this->cs->getBeginLine())
#      $this->assertEquals(1, $this->cs->getEndColumn())
#      $this->assertEquals(1, $this->cs->getEndColumn())
  end
 
  def test_read_char_with_unicode
#      $this->cs = new CharStream(new StringReader('ðinæ'))
#      $this->assertEquals('ð', $this->cs->readChar())
#      $this->assertEquals('i', $this->cs->readChar())
#      $this->assertEquals('n', $this->cs->readChar())
#      $this->assertEquals('æ', $this->cs->readChar())
  end
#    
#    /**
#     * @expectedException Exception
#     */
  def test_read_char_till_eof_with_unicode
#      $this->cs = new CharStream(new StringReader('ðinæ'))
#      $this->cs->readChar()
#      $this->cs->readChar()
#      $this->cs->readChar()
#      $this->cs->readChar()
#      $this->cs->readChar()
  end

  def test_get_image_with_unicode
#      $this->cs = new CharStream(new StringReader('ðinæ'))
#      $this->cs->readChar()
#      $this->cs->readChar()
#      $this->assertEquals('ði', $this->cs->getImage())
  end
  
end