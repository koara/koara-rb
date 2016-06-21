# encoding: utf-8
require 'koara'
require 'minitest/autorun'

class StringReaderTest < MiniTest::Unit::TestCase
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
    @reader = StringReader.new('abcd')
    assert_equal(2, @reader.read(@buffer, 0, 2))
    assert_equal('a', @buffer[0])
    assert_equal('b', @buffer[1])
    assert_equal(2, @buffer.length)
  end

  def test_read_with_offset_part_of_string
    @reader = StringReader.new('abcd')
    assert_equal(4, @reader.read(@buffer, 2, 4))
    assert_equal(nil, @buffer[0])
    assert_equal(nil, @buffer[1])
    assert_equal('a', @buffer[2])
    assert_equal('b', @buffer[3])
  end

  def test_read_with_offset_too_large_part_of_string
    @reader = StringReader.new('abcd')
    assert_equal(4, @reader.read(@buffer, 6, 4))
    assert_equal(nil, @buffer[0])
    assert_equal(nil, @buffer[1])
    assert_equal(nil, @buffer[2])
    assert_equal(nil, @buffer[3])
  end

  def test_read_until_eof
    @reader = StringReader.new('abcd')
    assert_equal(2, @reader.read(@buffer, 0, 2))
    assert_equal('a', @buffer[0])
    assert_equal('b', @buffer[1])
    assert_equal(2, @reader.read(@buffer, 0, 3))
    assert_equal('c', @buffer[0])
    assert_equal('d', @buffer[1])
    assert_equal(-1, @reader.read(@buffer, 0, 2))
  end

  def test_read_with_unicode
    @reader = StringReader.new('ðinæ')
    assert_equal(4, @reader.read(@buffer, 0, 4))
    assert_equal('ð', @buffer[0])
    assert_equal('i', @buffer[1])
    assert_equal('n', @buffer[2])
    assert_equal('æ', @buffer[3])
    assert_equal(4, @buffer.length)
  end

  def test_read_with_unicode_part_of_string
    @reader = StringReader.new('ðinæ')
    assert_equal(2, @reader.read(@buffer, 0, 2))
    assert_equal('ð', @buffer[0])
    assert_equal('i', @buffer[1])
    assert_equal(2, @buffer.length)
  end

  def test_Read_with_unicode_and_offset_part_of_string
    @reader = StringReader.new('ðinæ')
    assert_equal(4, @reader.read(@buffer, 2, 4))
    assert_equal(nil, @buffer[0])
    assert_equal(nil, @buffer[1])
    assert_equal('ð', @buffer[2])
    assert_equal('i', @buffer[3])
  end

  def test_read_with_unicode_and_offset_too_large_part_of_string
    @reader = StringReader.new('ðinæ')
    assert_equal(4, @reader.read(@buffer, 6, 4))
    assert_equal(nil, @buffer[0])
    assert_equal(nil, @buffer[1])
    assert_equal(nil, @buffer[2])
    assert_equal(nil, @buffer[3])
  end

  def test_read_with_unicode_until_eof
    @reader = StringReader.new('ðinæ')
    assert_equal(3, @reader.read(@buffer, 0, 3))
    assert_equal('ð', @buffer[0])
    assert_equal('i', @buffer[1])
    assert_equal(1, @reader.read(@buffer, 0, 3))
    assert_equal('æ', @buffer[0])
    assert_equal(-1, @reader.read(@buffer, 0, 2))
  end

end