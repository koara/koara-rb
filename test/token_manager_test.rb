require 'koara'
require 'minitest/autorun'

class TokenManagerTest < MiniTest::Unit::TestCase


  def test_eof
   token = TokenManager.new(CharStream.new(StringReader.new('')))::get_next_token
   assert_equal(TokenManager::EOF, token.kind)
  end

  def test_asterisk
    token = TokenManager.new(CharStream.new(StringReader.new('*'))).get_next_token
    assert_equal(TokenManager::ASTERISK, token.kind)
    assert_equal('*', token.image)
  end

  def test_backslash
    token = TokenManager.new(CharStream.new(StringReader.new('\\'))).get_next_token
    assert_equal(TokenManager::BACKSLASH, token.kind)
    assert_equal('\\', token.image)
  end

  def test_backtick
    token = TokenManager.new(CharStream.new(StringReader.new('`'))).get_next_token
    assert_equal(TokenManager::BACKTICK, token.kind)
    assert_equal('`', token.image)
  end

  def test_char_sequence_lowercase
    token = TokenManager.new(CharStream.new(StringReader.new('m'))).get_next_token
    assert_equal(TokenManager::CHAR_SEQUENCE, token.kind)
    assert_equal('m', token.image)
  end

  def test_char_sequence_uppercase
    token = TokenManager.new(CharStream.new(StringReader.new('C'))).get_next_token
    assert_equal(TokenManager::CHAR_SEQUENCE, token.kind)
    assert_equal('C', token.image)
  end

  def test_colon
    token = TokenManager.new(CharStream.new(StringReader.new(':'))).get_next_token
    assert_equal(TokenManager::COLON, token.kind)
    assert_equal(':', token.image)
  end

  def test_dash
    token = TokenManager.new(CharStream.new(StringReader.new('-'))).get_next_token
    assert_equal(TokenManager::DASH, token.kind)
    assert_equal('-', token.image)
  end

  def test_digits
    token = TokenManager.new(CharStream.new(StringReader.new('4'))).get_next_token
    assert_equal(TokenManager::DIGITS, token.kind)
    assert_equal('4', token.image)
  end

  def test_dot
    token = TokenManager.new(CharStream.new(StringReader.new('.'))).get_next_token
    assert_equal(TokenManager::DOT, token.kind)
    assert_equal('.', token.image)
  end

  def test_eol
    token = TokenManager.new(CharStream.new(StringReader.new("\n"))).get_next_token
    assert_equal(TokenManager::EOL, token.kind)
    assert_equal("\n", token.image)
  end

  def test_eq
    token = TokenManager.new(CharStream.new(StringReader.new('='))).get_next_token
    assert_equal(TokenManager::EQ, token.kind)
    assert_equal('=', token.image)
  end

  def test_escaped_char
    token = TokenManager.new(CharStream.new(StringReader.new("\\*"))).get_next_token
    assert_equal(TokenManager::ESCAPED_CHAR, token.kind)
    assert_equal("\\*", token.image)
  end

  def test_gt
    token = TokenManager.new(CharStream.new(StringReader.new('>'))).get_next_token
    assert_equal(TokenManager::GT, token.kind)
    assert_equal('>', token.image)
  end

  def test_image_label
    token = TokenManager.new(CharStream.new(StringReader.new('image:'))).get_next_token
    assert_equal(TokenManager::IMAGE_LABEL, token.kind)
    assert_equal('image:', token.image)
  end

  def test_lbrack
    token = TokenManager.new(CharStream.new(StringReader.new('['))).get_next_token
    assert_equal(TokenManager::LBRACK, token.kind)
    assert_equal('[', token.image)
  end

  def test_lparen
    token = TokenManager.new(CharStream.new(StringReader.new('('))).get_next_token
    assert_equal(TokenManager::LPAREN, token.kind)
    assert_equal('(', token.image)
  end

  def test_lt
    token = TokenManager.new(CharStream.new(StringReader.new('<'))).get_next_token
    assert_equal(TokenManager::LT, token.kind)
    assert_equal('<', token.image)
  end

  def test_rbrack
    token = TokenManager.new(CharStream.new(StringReader.new(']'))).get_next_token
    assert_equal(TokenManager::RBRACK, token.kind)
    assert_equal(']', token.image)
  end

  def test_rparen
    token = TokenManager.new(CharStream.new(StringReader.new(')'))).get_next_token
    assert_equal(TokenManager::RPAREN, token.kind)
    assert_equal(')', token.image)
  end

  def test_space
    token = TokenManager.new(CharStream.new(StringReader.new(' '))).get_next_token
    assert_equal(TokenManager::SPACE, token.kind)
    assert_equal(' ', token.image)
  end

  def test_tab
    token = TokenManager.new(CharStream.new(StringReader.new("\t"))).get_next_token
    assert_equal(TokenManager::TAB, token.kind)
    assert_equal("\t", token.image)
  end

  def test_underscore
    token = TokenManager.new(CharStream.new(StringReader.new('_'))).get_next_token
    assert_equal(TokenManager::UNDERSCORE, token.kind)
    assert_equal('_', token.image)
  end

  def test_space_after_char_sequence
    tm = TokenManager.new(CharStream.new(StringReader.new('a ')))
    assert_equal('a', tm.get_next_token.image)
    assert_equal(' ', tm.get_next_token.image)
  end

  def test_two_distinct_char_sequences
    tm = TokenManager.new(CharStream.new(StringReader.new('ði ı')))
    assert_equal('ði', tm.get_next_token.image)
    assert_equal(' ', tm.get_next_token.image)
    assert_equal('ı', tm.get_next_token.image)
  end

end