# encoding: utf-8
require 'koara'
require 'minitest/autorun'

class TokenManagerTest < MiniTest::Unit::TestCase


  def test_eof
   token = Koara::TokenManager.new(Koara::CharStream.new(Koara::Io::StringReader.new('')))::get_next_token
   assert_equal(Koara::TokenManager::EOF, token.kind)
  end

  def test_asterisk
    token = Koara::TokenManager.new(Koara::CharStream.new(Koara::Io::StringReader.new('*'))).get_next_token
    assert_equal(Koara::TokenManager::ASTERISK, token.kind)
    assert_equal('*', token.image)
  end

  def test_backslash
    token = Koara::TokenManager.new(Koara::CharStream.new(Koara::Io::StringReader.new('\\'))).get_next_token
    assert_equal(TokenManager::BACKSLASH, token.kind)
    assert_equal('\\', token.image)
  end

  def test_backtick
    token = Koara::TokenManager.new(Koara::CharStream.new(Koara::Io::StringReader.new('`'))).get_next_token
    assert_equal(Koara::TokenManager::BACKTICK, token.kind)
    assert_equal('`', token.image)
  end

  def test_char_sequence_lowercase
    token = Koara::TokenManager.new(Koara::CharStream.new(Koara::Io::StringReader.new('m'))).get_next_token
    assert_equal(Koara::TokenManager::CHAR_SEQUENCE, token.kind)
    assert_equal('m', token.image)
  end

  def test_char_sequence_uppercase
    token = Koara::TokenManager.new(Koara::CharStream.new(Koara::Io::StringReader.new('C'))).get_next_token
    assert_equal(Koara::TokenManager::CHAR_SEQUENCE, token.kind)
    assert_equal('C', token.image)
  end

  def test_colon
    token = Koara::TokenManager.new(Koara::CharStream.new(Koara::Io::StringReader.new(':'))).get_next_token
    assert_equal(Koara::TokenManager::COLON, token.kind)
    assert_equal(':', token.image)
  end

  def test_dash
    token = Koara::TokenManager.new(Koara::CharStream.new(Koara::Io::StringReader.new('-'))).get_next_token
    assert_equal(Koara::TokenManager::DASH, token.kind)
    assert_equal('-', token.image)
  end

  def test_digits
    token = Koara::TokenManager.new(Koara::CharStream.new(Koara::Io::StringReader.new('4'))).get_next_token
    assert_equal(Koara::TokenManager::DIGITS, token.kind)
    assert_equal('4', token.image)
  end

  def test_dot
    token = Koara::TokenManager.new(Koara::CharStream.new(Koara::Io::StringReader.new('.'))).get_next_token
    assert_equal(Koara::TokenManager::DOT, token.kind)
    assert_equal('.', token.image)
  end

  def test_eol
    token = Koara::TokenManager.new(Koara::CharStream.new(Koara::Io::StringReader.new("\n"))).get_next_token
    assert_equal(Koara::TokenManager::EOL, token.kind)
    assert_equal("\n", token.image)
  end

  def test_eq
    token = Koara::TokenManager.new(Koara::CharStream.new(Koara::Io::StringReader.new('='))).get_next_token
    assert_equal(Koara::TokenManager::EQ, token.kind)
    assert_equal('=', token.image)
  end

  def test_escaped_char
    token = Koara::TokenManager.new(Koara::CharStream.new(Koara::Io::StringReader.new("\\*"))).get_next_token
    assert_equal(Koara::TokenManager::ESCAPED_CHAR, token.kind)
    assert_equal("\\*", token.image)
  end

  def test_gt
    token = Koara::TokenManager.new(Koara::CharStream.new(Koara::Io::StringReader.new('>'))).get_next_token
    assert_equal(Koara::TokenManager::GT, token.kind)
    assert_equal('>', token.image)
  end

  def test_image_label
    token = Koara::TokenManager.new(Koara::CharStream.new(Koara::Io::StringReader.new('image:'))).get_next_token
    assert_equal(Koara::TokenManager::IMAGE_LABEL, token.kind)
    assert_equal('image:', token.image)
  end

  def test_lbrack
    token = Koara::TokenManager.new(Koara::CharStream.new(Koara::Io::StringReader.new('['))).get_next_token
    assert_equal(Koara::TokenManager::LBRACK, token.kind)
    assert_equal('[', token.image)
  end

  def test_lparen
    token = Koara::TokenManager.new(Koara::CharStream.new(Koara::Io::StringReader.new('('))).get_next_token
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