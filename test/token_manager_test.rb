# encoding: utf-8
require 'test_helper'

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
    assert_equal(Koara::TokenManager::BACKSLASH, token.kind)
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
  
  def test_eol_with_spaces
    token = Koara::TokenManager.new(Koara::CharStream.new(Koara::Io::StringReader.new("  \n"))).get_next_token
    assert_equal(Koara::TokenManager::EOL, token.kind)
    assert_equal("  \n", token.image)
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
    assert_equal(Koara::TokenManager::LPAREN, token.kind)
    assert_equal('(', token.image)
  end

  def test_lt
    token = Koara::TokenManager.new(Koara::CharStream.new(Koara::Io::StringReader.new('<'))).get_next_token
    assert_equal(Koara::TokenManager::LT, token.kind)
    assert_equal('<', token.image)
  end

  def test_rbrack
    token = Koara::TokenManager.new(Koara::CharStream.new(Koara::Io::StringReader.new(']'))).get_next_token
    assert_equal(Koara::TokenManager::RBRACK, token.kind)
    assert_equal(']', token.image)
  end

  def test_rparen
    token = Koara::TokenManager.new(Koara::CharStream.new(Koara::Io::StringReader.new(')'))).get_next_token
    assert_equal(Koara::TokenManager::RPAREN, token.kind)
    assert_equal(')', token.image)
  end

  def test_space
    token = Koara::TokenManager.new(Koara::CharStream.new(Koara::Io::StringReader.new(' '))).get_next_token
    assert_equal(Koara::TokenManager::SPACE, token.kind)
    assert_equal(' ', token.image)
  end

  def test_tab
    token = Koara::TokenManager.new(Koara::CharStream.new(Koara::Io::StringReader.new("\t"))).get_next_token
    assert_equal(Koara::TokenManager::TAB, token.kind)
    assert_equal("\t", token.image)
  end

  def test_underscore
    token = Koara::TokenManager.new(Koara::CharStream.new(Koara::Io::StringReader.new('_'))).get_next_token
    assert_equal(Koara::TokenManager::UNDERSCORE, token.kind)
    assert_equal('_', token.image)
  end

  def test_linebreak
  	tm = Koara::TokenManager.new(Koara::CharStream.new(Koara::Io::StringReader.new("a\nb")))
    token = tm.get_next_token
    assert_equal(Koara::TokenManager::CHAR_SEQUENCE, token.kind)
    assert_equal('a', token.image)
    token = tm.get_next_token
    assert_equal(Koara::TokenManager::EOL, token.kind)
    assert_equal("\n", token.image)
    token = tm.get_next_token
    assert_equal(Koara::TokenManager::CHAR_SEQUENCE, token.kind)    
  end
  
  

end