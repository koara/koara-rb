require_relative '../lib/token_manager'
require_relative '../lib/charstream'
require_relative '../lib/io/stringreader'
require "test/unit"

class TokenManagerTest < Test::Unit::TestCase


  #def test_eof
  #  token = TokenManager.new(CharStream.new(StringReader.new('')))::get_next_token
  #  assert_equal(TokenManager.EOF, token.kind)
  #end

  def test_asterisk
    token = TokenManager.new(CharStream.new(StringReader.new('*'))).get_next_token
    assert_equal(TokenManager::ASTERISK, token.kind)
    assert_equal('*', token.image)
  end

end