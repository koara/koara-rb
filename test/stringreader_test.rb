require_relative '../lib/stringreader'
require "test/unit"

class StringReaderTest < Test::Unit::TestCase
  
  def setup
    @buffer = Array.new
  end
  
  def test_read
    @reader = StringReader.new('abcd')
    assert_equal(4, @reader.read(@buffer, 0, 4))
    assert_equal('a', @buffer[0])
    assert_equal('b', @buffer[1])
    assert_equal('c', @buffer[2])
    assert_equal('d', @buffer[3])
    assert_equal(4, @buffer.length)
    assert_equal(-1, @reader.read(@buffer, 0, 4))
  end

  def test_read_part_of_string
  #      $reader = new StringReader('abcd');
  #      $this->assertEquals(2, $reader->read($this->buffer, 0, 2));
  #      $this->assertEquals('a', $this->buffer[0]);
  #      $this->assertEquals('b', $this->buffer[1]);
  #      $this->assertEquals(2, count($this->buffer));
  end
  #
  #    public function testReadWithOffsetPartOfString() {
  #      $reader = new StringReader('abcd');
  #      $this->assertEquals(4, $reader->read($this->buffer, 2, 4));
  #      $this->assertFalse(array_key_exists(0, $this->buffer));
  #      $this->assertFalse(array_key_exists(1, $this->buffer));
  #      $this->assertEquals('a', $this->buffer[2]);
  #      $this->assertEquals('b', $this->buffer[3]);
  #     }
  #
  #     public function testReadWithOffsetTooLargePartOfString() {
  #      $reader = new StringReader('abcd');
  #      $this->assertEquals(4, $reader->read($this->buffer, 6, 4));
  #      $this->assertFalse(array_key_exists(0, $this->buffer));
  #      $this->assertFalse(array_key_exists(1, $this->buffer));
  #      $this->assertFalse(array_key_exists(2, $this->buffer));
  #      $this->assertFalse(array_key_exists(3, $this->buffer));
  #     }
  #
  #    public function testReadUntilEof() {
  #      $reader = new StringReader('abcd');
  #      $this->assertEquals(2, $reader->read($this->buffer, 0, 2));
  #      $this->assertEquals('a', $this->buffer[0]);
  #      $this->assertEquals('b', $this->buffer[1]);
  #
  #      $this->assertEquals(2, $reader->read($this->buffer, 0, 3));
  #      $this->assertEquals('c', $this->buffer[0]);
  #      $this->assertEquals('d', $this->buffer[1]);
  #
  #      $this->assertEquals(-1, $reader->read($this->buffer, 0, 2));
  #    }
  #
  #     public function testReadWithUnicode() {
  #      $reader = new StringReader('ðinæ');
  #      $this->assertEquals(4, $reader->read($this->buffer, 0, 4));
  #      $this->assertEquals('ð', $this->buffer[0]);
  #      $this->assertEquals('i', $this->buffer[1]);
  #      $this->assertEquals('n', $this->buffer[2]);
  #      $this->assertEquals('æ', $this->buffer[3]);
  #      $this->assertEquals(4, count($this->buffer));
  #     }
  #
  #     public function testReadWithUnicodePartOfString() {
  #      $reader = new StringReader('ðinæ');
  #      $this->assertEquals(2, $reader->read($this->buffer, 0, 2));
  #      $this->assertEquals('ð', $this->buffer[0]);
  #      $this->assertEquals('i', $this->buffer[1]);
  #      $this->assertEquals(2, count($this->buffer));
  #     }
  #
  #     public function testReadWithUnicodeAndOffsetPartOfString() {
  #      $reader = new StringReader('ðinæ');
  #      $this->assertEquals(4, $reader->read($this->buffer, 2, 4));
  #      $this->assertFalse(array_key_exists(0, $this->buffer));
  #      $this->assertFalse(array_key_exists(1, $this->buffer));
  #      $this->assertEquals('ð', $this->buffer[2]);
  #      $this->assertEquals('i', $this->buffer[3]);
  #     }
  #
  #     public function testReadWithUnicodeAndOffsetTooLargePartOfString() {
  #      $reader = new StringReader('ðinæ');
  #      $this->assertEquals(4, $reader->read($this->buffer, 6, 4));
  #      $this->assertFalse(array_key_exists(0, $this->buffer));
  #      $this->assertFalse(array_key_exists(1, $this->buffer));
  #      $this->assertFalse(array_key_exists(2, $this->buffer));
  #      $this->assertFalse(array_key_exists(3, $this->buffer));
  #     }
  #
  #     public function testReadWithUnicodeUntilEof() {
  #      $reader = new StringReader('ðinæ');
  #      $this->assertEquals(3, $reader->read($this->buffer, 0, 3));
  #      $this->assertEquals('ð', $this->buffer[0]);
  #      $this->assertEquals('i', $this->buffer[1]);
  #
  #      $this->assertEquals(1, $reader->read($this->buffer, 0, 3));
  #      $this->assertEquals('æ', $this->buffer[0]);
  #
  #      $this->assertEquals(-1, $reader->read($this->buffer, 0, 2));
  #     }

end