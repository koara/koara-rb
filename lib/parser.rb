require_relative 'charstream'
require_relative 'io/stringreader'
require_relative 'lookahead_success'
require_relative 'token'
require_relative 'token_manager'
require_relative 'tree_state'

class Parser
  attr_reader :modules
  def initialize()
    @lookAheadSuccess = LookaheadSuccess.new
    @modules = ["paragraphs", "headings", "lists", "links", "images", "formatting", "blockquotes", "code"]
  end

  def parse(text)
    return parse_reader(StringReader.new(text))
  end

  def parse_file(file)

    #      if(!file.getName().toLowerCase().endsWith(".kd")) {
    #        throw new IllegalArgumentException("Can only parse files with extension .kd")
    #      }
    return parse_reader(FileReader.new(file))
  end

  def parse_reader(reader)
    @cs =  CharStream.new(reader)
    @tm =  TokenManager.new(@cs)
    @token =  Token.new
    @tree = TreeState.new
    @nextTokenKind = -1
    document = Document.new
    @tree.open_scope()

    while(get_next_token_kind() == TokenManager::EOL)
      consume_token(TokenManager::EOL)
    end
    white_space()
    if (has_any_block_elements_ahead())
      block_element()
      while (block_ahead(0))
        while (get_next_token_kind() == TokenManager::EOL)
          consume_token(TokenManager::EOL)
          white_space()
        end
        block_element()
      end
      while (get_next_token_kind() == TokenManager::EOL)
        consume_token(TokenManager::EOL)
      end
      white_space()
    end
    consume_token(TokenManager::EOF)
    @tree.close_scope(document)
    return document
  end

  def block_element()
    @current_block_level += 1
    if (modules.include?("headings") && heading_ahead(1))
      heading()
    elsif (modules.include?("blockquotes") && get_next_token_kind() == TokenManager::GT)
      block_quote()
    elsif (modules.include?("lists") && get_next_token_kind() == TokenManager::DASH)
      unordered_list()
    elsif (modules.include?("lists") && has_ordered_list_ahead())
      ordered_list()
    elsif (modules.contains("code") && has_fenced_code_block_ahead())
      fenced_code_block()
    else
      paragraph()
    end
    @current_block_level -= 1
  end

  def heading()
    heading =  Heading.new
    @tree.open_scope()
    heading_level = 0

    while (get_next_token_kind() == TokenManager::EQ)
      consume_token(TokenManager::EQ)
      heading_level += 1
    end
    white_space()
    while (heading_has_inline_elementsAhead())
      if (has_text_ahead())
        text()
      elsif (modules.contains("images") && has_image_ahead())
        image()
      elsif (modules.contains("links") && has_link_ahead())
        link()
      elsif (modules.contains("formatting") && has_strong_ahead())
        strong()
      elsif (modules.contains("formatting") && has_em_ahead())
        em()
      elsif (modules.contains("code") && has_code_ahead())
        code()
      else
        loose_char()
      end
    end
    heading.value = headingLevel
    @tree.close_scope(heading)
  end

  def block_quote()
    blockquote = BlockQuote.new
    @tree.open_scope()
    @current_quote_Level += 1
    consume_token(TokenManager::GT)
    while (block_quote_has_empty_line_ahead())
      block_quote_empty_line()
    end
    white_space()
    if (block_quote_has_any_block_elements_ahead())
      block_element()
      while (block_ahead(0))
        while (getNextTokenKind() == TokenManager::EOL)
          consume_token(TokenManager::EOL)
          white_space()
          block_quote_prefix()
        end
        block_element()
      end
    end
    while (hasBlockQuoteEmptyLinesAhead())
      block_quote_empty_line()
    end
    current_quote_level -= 1
    @tree.close_scope(blockquote)
  end

  def block_quote_prefix()
    i = 0
    loop do
      consume_token(TokenManager::GT)
      white_space()
      break if(i+1 >= @current_quote_level)
    end
  end

  def block_quote_empty_line()
    consume_token(TokenManager::TokenManager::EOL)
    white_space()
    loop do
      consume_token(TokenManager::GT)
      white_space()
      break if(get_next_toen_kind() != TokenManager::GT)
    end
  end

  def unordered_list()
    list =  ListBlock.new(false)
    @tree.open_scope()
    listBeginColumn = unordered_list_item()
    while (list_item_ahead(list_begin_column, false))
      while (get_next_token_kind() == TokenManager::EOL)
        consume_token(TokenManager::EOL)
      end
      white_space()
      if (currentQuoteLevel > 0)
        block_quote_prefix()
      end
      unordered_list_item()
    end
    @tree.close_scope(list)
  end

  def unordered_list_item()
    listItem = ListItem.new
    @tree.open_scope()

    t = consumeToken(TokenManager::DASH)
    white_space()
    if (list_item_has_inline_elements())
      block_element()
      while (block_ahead(t.beginColumn))
        while (get_next_token_kind() == TokenManager::EOL)
          consume_token(TTokenManager::EOL)
          white_space()
          if (currentQuoteLevel > 0)
            block_quote_prefix()
          end
        end
        block_element()
      end
    end
    @tree.close_scope(list_item)
    return t.beginColumn
  end

  def ordered_list()
    list = ListBlock.new(true)
    @tree.open_scope()
    listBeginColumn = ordered_list_item()
    while (listItemAhead(listBeginColumn, true))
      while (get_next_token_kind() == TokenManager::EOL)
        consume_token(TokenManager::EOL)
      end
      white_space()
      if (currentQuoteLevel > 0)
        block_quote_prefix()
      end
      ordered_list_item()
    end
    @tree.closeScope(list)
  end

  def ordered_list_item()
    list_item = ListItem.new
    @tree.open_scope()
    t = consume_token(TokenManager::DIGITS)
    consume_token(TokenManager::DOT)
    white_space()
    if (list_item_has_inline_elements())
      block_element()
      while (block_ahead(t.begin_column))
        while (get_next_token_kind() == TokenManager::EOL)
          consume_token(TokenManager::EOL)
          white_space()
          if (current_quote_level > 0)
            block_quote_prefix()
          end
        end
        block_element()
      end
    end
    list_item.number = t.image
    @tree.close_scope(list_item)
    return t.begin_column
  end

  def fenced_code_block()
    code_block = CodeBlock.new
    @tree.open_scope()
    s = StringIO.new
    begin_column = consume_token(TokenManager::BACKTICK).begin_column
    loop do
      consume_token(TokenManager::BACKTICK)
      break if (get_next_token_kind() != TokenManager::BACKTICK)
    end
    white_space()
    if (get_next_token_kind() == TokenManager::CHAR_SEQUENCE)
      code_block.language = code_language()
    end
    if (get_next_token_kind() != TokenManager::EOF && !fences_ahead())
      consume_token(TokenManager::EOL)
      level_white_space(begin_column)
    end

    kind = get_next_token_kind()
    while (kind != TokenManager::EOF && ((kind != TokenManager::EOL && kind != TokenManager::BACKTICK) || !fences_ahead()))

      case kind
      when TokenManager::CHAR_SEQUENCE
        s << consume_token(TokenManager::CHAR_SEQUENCE).image
      when TokenManager::ASTERISK
        s << consume_token(TokenManager::ASTERISK).image
      when TokenManager::BACKSLASH
        s << consume_token(TokenManager::BACKSLASH).image
      when TokenManager::COLON
        s << consume_token(TokenManager::COLON).image
      when TokenManager::DASH
        s << consume_token(TokenManager::DASH).image
      when TokenManager::DIGITS
        s << consume_token(TokenManager::DIGITS).image
      when TokenManager::DOT
        s << consume_token(TokenManager::DOT).image
      when TokenManager::EQ
        s << consume_token(TokenManager::EQ).image
      when TokenManager::ESCAPED_CHAR
        s << consume_token(TokenManager::ESCAPED_CHAR).image
      when TokenManager::IMAGE_LABEL
        s << consume_token(TokenManager::IMAGE_LABEL).image
      when TokenManager::LT
        s << consume_token(TokenManager::LT).image
      when TokenManager::GT
        s << consume_token(TokenManager::GT).image
      when TokenManager::LBRACK
        s << consume_token(TokenManager::LBRACK).image
      when TokenManager::RBRACK
        s << consume_token(TokenManager::RBRACK).image
      when TokenManager::LPAREN
        s << consume_token(TokenManager::LPAREN).image
      when TokenManager::RPAREN
        s << consume_token(TokenManager::RPAREN).image
      when TokenManager::UNDERSCORE
        s << consume_token(TokenManager::UNDERSCORE).image
      when TokenManager::BACKTICK
        s << consume_token(TokenManager::BACKTICK).image
      else
        if (!next_after_space(TokenManager::EOL, TokenManager::EOF))
          case kind
          when TokenManager::SPACE
            s << consume_token(TokenManager::SPACE).image
          when TokenManager::TAB
            consume_token(TokenManager::TAB)
            s << consume_token("    ")
          end
        elsif (!fences_ahead())
          consume_token(TokenManager::EOL)
          s << "\n"
          level_white_space(begin_column)
        end
      end
      kind = get_next_token_kind()
    end
    if (fences_ahead())
      consume_token(TokenManager::TokenManager::EOL)
      white_space()
      while (get_next_token_kind() == TokenManager::BACKTICK)
        consume_token(TokenManager::BACKTICK)
      end
    end
    codeBlock.value = s
    @tree.close_scope(code_block)
  end

  def paragraph()
    paragraph = modules.includes?("paragraphs") ? Paragraph.new : BlockElement.new
    @tree.open_scope()
    inline()
    while (textAhead())
      line_break()
      white_space()
      if (modules.includes?("blockquotes"))
        while (get_next_token_kind() == TokenManager::GT)
          consume_token(TokenManager::GT)
          white_space()
        end
      end
      inline()
    end
    @tree.close_scope(paragraph)
  end

  def text()
    text = Text.new
    @tree.open_scope()
    s = StringIO.new
    while (text_has_tokens_ahead())
      case get_next_token_kind()
      when TokenManager::CHAR_SEQUENCE
        s << consumeToken(TokenManager::CHAR_SEQUENCE).image
      when TokenManager::BACKSLASH
        s << consumeToken(TokenManager::BACKSLASH).image
      when TokenManager::COLON
        s << consumeToken(TokenManager::COLON).image
      when TokenManager::DASH
        s << consumeToken(TokenManager::DASH).image
      when TokenManager::DIGITS
        s << consumeToken(TokenManager::DIGITS).image
      when TokenManager::DOT
        s << consumeToken(TokenManager::DOT).image
      when TokenManager::EQ
        s << consumeToken(TokenManager::EQ).image
      when TokenManager::ESCAPED_CHAR
        s << consumeToken(TokenManager::ESCAPED_CHAR).image[1..-1]
      when TokenManager::GT
        s << consumeToken(TokenManager::GT).image
      when TokenManager::IMAGE_LABEL
        s << consumeToken(TokenManager::IMAGE_LABEL).image
      when TokenManager::LPAREN
        s << consumeToken(TokenManager::LPAREN).image
      when TokenManager::LT
        s << consumeToken(TokenManager::LT).image
      when TokenManager::RBRACK
        s << consumeToken(TokenManager::RBRACK).image
      when TokenManager::RPAREN
        s << consumeToken(TokenManager::RPAREN).image
      else
        if (!next_after_space(TokenManager::EOL, TokenManager::EOF))
          case get_next_token_kind()
          when TokenManager::SPACE
            s << consume_token(TokenManager::SPACE).image
          when TokenManager::TAB
            consume_token(TokenManager::TAB)
            s << "    "
          end
        end
      end
    end
    text.value = s
    @tree.close_scope(text)
  end

  def image()
    image = Image.new
    @tree.open_scope()
    ref = ""
    consume_token(TokenManager::LBRACK)
    white_space()
    consume_token(TokenManager::IMAGE_LABEL)
    white_space()
    while (imageHasAnyElements())
      if (hasTextAhead())
        resource_text()
      else
        loose_char()
      end
    end
    white_space()
    consume_token(TokenManager::RBRACK)
    if (has_resource_url_ahead())
      ref = resource_url()
    end
    image.value = ref
    @tree.close_scope(image)
  end

  def link()
    link = Link.new
    @tree.open_scope()
    ref = ""
    consume_token(TokenManager::LBRACK)
    white_space()
    while (link_has_any_elements())
      if (modules.includes?("images") && has_Image_ahead())
        image()
      elsif (modules.includes?("formatting") && has_strong_ahead())
        strong()
      elsif (modules.includes?("formatting") && has_em_ahead())
        em()
      elsif (modules.includes?("code") && has_code_ahead())
        code()
      elsif(has_resource_text_ahead())
        resource_text()
      else
        looseChar()
      end
    end
    white_space()
    consume_token(TokenManager::RBRACK)
    if (hasResourceUrlAhead())
      ref = resource_url()
    end
    link.value = ref
    @tree.close_scope(link)
  end

  def strong()
    strong = Strong.new
    @tree.open_scope()
    consume_token(TokenManager::ASTERISK)
    while (strong_has_elements())
      if (has_text_ahead())
        text()
      elsif (modules.includes?("images") && has_image())
        image()
      elsif (modules.includes?("links") && has_link_ahead())
        link()
      elsif (modules.includes?("code") && multiline_ahead(TokenManager::BACKTICK))
        code_multiline()
      elsif (strongEmWithinStrongAhead())
        em_within_strong()
      else
        case get_next_token_kind()
        when TokenManager::BACKTICK
          @tree.add_single_value(Text.new, consume_token(TokenManager::BACKTICK))
        when TokenManager::LBRACK
          @tree.add_single_value(Text.new, consume_token(TokenManager::LBRACK))
        when TokenManager::UNDERSCORE
          @tree.add_single_value(Text.w, consume_token(TokenManager::UNDERSCORE))
        end
      end
    end
    consume_token(TokenManager::ASTERISK)
    @tree.close_scope(strong)
  end

  def em()
    em = Em.new
    @tree.open_scope()
    consume_Token(TokenManager::UNDERSCORE)
    while (em_has_elements())
      if (has_text_ahead())
        text()
      elsif (modules.includes?("images") && has_image())
        image()
      elsif (modules.includes?("links") && has_link_ahead())
        link()
      elsif (modules.includes?("code") && has_code_ahead())
        code()
      elsif (em_has_strong_within_em())
        strong_within_em()
      else
        case get_next_token_kind()
        when TokenManager::ASTERISK
          @tree.add_single_value(Text.new, consume_token(TokenManager::ASTERISK))
        when TokenManager::BACKTICK
          @tree.add_single_value(Text.new, consume_token(TokenManager::BACKTICK))
        when TokenManager::LBRACK
          @tree.add_single_value(Text.new, consume_token(TokenManager::LBRACK))
        end
      end
    end
    consume_token(TokenManager::UNDERSCORE)
    tree.close_scope(em)
  end

  def code()
    code = Code.new
    @tree.open_scope()
    consume_token(TokenManager::BACKTICK)
    code_text()
    consumetToken(TokenManager::BACKTICK)
    @tree.close_scope(code)
  end

  def code_text()
    text = Text.new
    @tree.open_scope()
    s = StringIO.new
    loop do
      case get_next_token_kind()
      when TokenManager::CHAR_SEQUENCE
        s << consumeToken(TokenManager::CHAR_SEQUENCE).image
      when TokenManager::ASTERISK
        s << consume_token(TokenManager::ASTERISK).image
      when TokenManager::BACKSLASH
        s << consume_token(TokenManager::BACKSLASH).image
      when TokenManager::COLON
        s << consume_token(TokenManager::COLON).image
      when TokenManager::DASH
        s << consume_token(TokenManager::DASH).image
      when TokenManager::DIGITS
        s << consume_token(TokenManager::DIGITS).image
      when TokenManager::DOT
        s << consume_token(TokenManager::DOT).image
      when TokenManager::EQ
        s << consume_token(TokenManager::EQ).image
      when TokenManager::ESCAPED_CHAR
        s << consume_token(TokenManager::ESCAPED_CHAR).image
      when TokenManager::IMAGE_LABEL
        s << consume_token(TokenManager::IMAGE_LABEL).image
      when TokenManager::LT
        s << consume_token(TokenManager::LT).image
      when TokenManager::LBRACK
        s << consume_token(TokenManager::LBRACK).image
      when TokenManager::RBRACK
        s << consume_token(TokenManager::RBRACK).image
      when TokenManager::LPAREN
        s << consume_token(TokenManager::LPAREN).image
      when TokenManager::GT
        s << consume_token(TokenManager::GT).image
      when TokenManager::RPAREN
        s << consume_token(TokenManager::RPAREN).image
      when TokenManager::UNDERSCORE
        s << consume_token(TokenManager::UNDERSCORE).image
      else
        if (!next_after_space(TokenManager::EOL, TokenManager::EOF))
          case get_next_token_kind()
          when TokenManager::SPACE
            s << consume_token(TokenManager::SPACE).image
          when TokenManager::SPACE
            consume_token(TokenManager::TAB)
            s << "    "
          end
        end
      end

      break if !code_text_has_any_token_ahead()
    end
    text.value = s
    @tree.close_scope(text)
  end

  def loose_char()
    text = Text.new
    @tree.open_scope()
    case (get_next_token_kind())
    when TokenManager::ASTERISK
      text.value = consume_token(TokenManager::ASTERISK).image
    when TokenManager::BACKTICK
      text.value = consume_token(TokenManager::BACKTICK).image
    when TokenManager::LBRACK
      text.value = consume_token(TokenManager::LBRACK).image
    when TokenManager::UNDERSCORE
      text.value = consume_token(TokenManager::UNDERSCORE).image
    end
    @tree.close_scope(text)
  end

  def line_break()
    linebreak = LineBreak.new
    tree.open_scope()
    while (get_next_token_kind() == TokenManager::SPACE || get_next_token_kind() == TokenManager::TAB)
      consumeToken(getNextTokenKind())
    end
    consume_token(TokenManager::EOL)
    tree.close_scope(linebreak)
  end

  def level_white_space()
    current_pos = 1
    while (get_next_token_kind() == TokenManager::GT)
      consume_token(get_next_token_kind())
    end
    while ((get_next_token_kind() == TokenManager::SPACE || get_next_token_kind() == TokenManager::TAB) && current_pos < (threshold - 1))
      current_pos = consume_token(get_next_token_kind()).begin_column
    end
  end

  def code_language()
    s = StringIO.new
    loop do
      case get_next_token_kind()
      when TokenManager::CHAR_SEQUENCE
        s << consume_token(TokenManager::CHAR_SEQUENCE).image
      when TokenManager::ASTERISK
        s << consume_token(TokenManager::ASTERISK).image
      when TokenManager::BACKSLASH
        s << consume_token(TokenManager::BACKSLASH).image
      when TokenManager::BACKTICK
        s << consume_token(TokenManager::BACKTICK).image
      when TokenManager::COLON
        s << consume_token(TokenManager::COLON).image
      when TokenManager::DASH
        s << consume_token(TokenManager::DASH).image
      when TokenManager::DIGITS
        s << consume_token(TokenManager::DIGITS).image
      when TokenManager::DOT
        s << consume_token(TokenManager::DOT).image
      when TokenManager::EQ
        s << consume_token(TokenManager::EQ).image
      when TokenManager::ESCAPED_CHAR
        s << consume_token(TokenManager::ESCAPED_CHAR).image
      when TokenManager::IMAGE_LABEL
        s << consume_token(TokenManager::IMAGE_LABEL).image
      when TokenManager::LT
        s << consume_token(TokenManager::LT).image
      when TokenManager::GT
        s << consume_token(TokenManager::GT).image
      when TokenManager::LBRACK
        s << consume_token(TokenManager::LBRACK).image
      when TokenManager::RBRACK
        s << consume_token(TokenManager::RBRACK).image
      when TokenManager::LPAREN
        s << consume_token(TokenManager::LPAREN).image
      when TokenManager::RPAREN
        s << consume_token(TokenManager::RPAREN).image
      when TokenManager::UNDERSCORE
        s << consume_token(TokenManager::UNDERSCORE).image
      when TokenManager::SPACE
        s << consume_token(TokenManager::SPACE).image
      when TokenManager::TAB
        consume_token(TokenManager::TAB)
        s << "    "
      end
      break if getNextTokenKind() == TokenManager::EOL || get_next_token_kind() == TokenManager::EOF
    end
    return s
  end

  def inline()
    loop do
      if (has_inline_text_ahead())
        text()
      elsif (modules.includes?("images") && has_image_ahead())
        image()
      elsif (modules.includes?("links") && has_link_ahead())
        link()
      elsif (modules.includes?("formatting") && multiline_ahead(TokenManager::ASTERISK))
        strong_multi_line()
      elsif (modules.includes?("formatting") && multiline_ahead(TokenManager::UNDERSCORE))
        em_multiline()
      elsif (modules.includes?("code") && multiline_ahead(TokenManager::BACKTICK))
        code_multiline()
      else
        loose_char()
      end
      break if !has_inline_element_ahead()
    end
  end

  def resource_text()
    text = Text.new
    @tree.open_scope()
    s = StringIO.new
    loop do
      case get_next_token_kind()
      when TokenManager::CHAR_SEQUENCE
        s << consume_token(TokenManager::CHAR_SEQUENCE).image
      when TokenManager::BACKSLASH
        s << consume_token(TokenManager::BACKSLASH).image
      when TokenManager::COLON
        s << consume_token(TokenManager::COLON).image
      when TokenManager::DASH
        s << consume_token(TokenManager::DASH).image
      when TokenManager::DIGITS
        s << consume_token(TokenManager::DIGITS).image
      when TokenManager::DOT
        s << consume_token(TokenManager::DOT).image
      when TokenManager::EQ
        s << consume_token(TokenManager::EQ).image
      when TokenManager::ESCAPED_CHAR
        s << consume_token(TokenManager::ESCAPED_CHAR).image[1..-1]
      when TokenManager::IMAGE_LABEL
        s << consume_token(TokenManager::IMAGE_LABEL).image
      when TokenManager::GT
        s << consume_token(TokenManager::GT).image
      when TokenManager::LPAREN
        s << consume_token(TokenManager::LPAREN).image
      when TokenManager::LT
        s << consume_token(TokenManager::LT).image
      when TokenManager::RPAREN
        s << consume_token(TokenManager::RPAREN).image
      else
        if (!next_after_space(TokenManager::RBRACK))
          case get_next_token_kind()
          when TokenManager::SPACE
            s << consume_token(TokenManager::SPACE).image
          when TokenManager::TAB
            consume_token(TokenManager::TAB)
            s << "    "
          end
        end
      end
      break if !resource_has_element_ahead()
    end
    text.value = s
    @tree.close_scope(text)
  end

  def resource_url()
    consume_token(TokenManager::LPAREN)
    white_space()
    ref = resourceUrltext()
    white_space()
    consume_token(TokenManager::RPAREN)
    return ref
  end

  def resource_url_text()
    s = StringIO.new
    while (resource_text_has_elements_ahead())
      case get_next_token_kind()
      when TokenManager::CHAR_SEQUENCE
        s << consumeToken(TokenManager::CHAR_SEQUENCE).image
      when TokenManager::ASTERISK
        s << consumeToken(TokenManager::ASTERISK).image
      when TokenManager::BACKSLASH
        s << consumeToken(TokenManager::BACKSLASH).image
      when TokenManager::BACKTICK
        s << consumeToken(TokenManager::BACKTICK).image
      when TokenManager::COLON
        s << consumeToken(TokenManager::COLON).image
      when TokenManager::DASH
        s << consumeToken(TokenManager::DASH).image
      when TokenManager::DIGITS
        s << consumeToken(TokenManager::DIGITS).image
      when TokenManager::DOT
        s << consumeToken(TokenManager::DOT).image
      when TokenManager::EQ
        s << consumeToken(TokenManager::EQ).image
      when TokenManager::ESCAPED_CHAR
        s << consumeToken(TokenManager::ESCAPED_CHAR).image[1..-1]
      when TokenManager::IMAGE_LABEL
        s << consumeToken(TokenManager::IMAGE_LABEL).image
      when TokenManager::GT
        s << consumeToken(TokenManager::GT).image
      when TokenManager::LBRACK
        s << consumeToken(TokenManager::LBRACK).image
      when TokenManager::LPAREN
        s << consumeToken(TokenManager::LPAREN).image
      when TokenManager::LT
        s << consumeToken(TokenManager::LT).image
      when TokenManager::RBRACK
        s << consumeToken(TokenManager::RBRACK).image
      when TokenManager::UNDERSCORE
        s << consumeToken(TokenManager::UNDERSCORE).image
      else
        if (!next_after_space(TokenManager::RPAREN))
          case get_next_token_kind()
          when okenManager::SPACE
            s << (consumeToken(TokenManager::SPACE).image)
          when TokenManager::TAB
            consume_token(TokenManager::TAB)
            s << "    "
          end
        end
      end
      return s
    end

    def strong_multiline()
      Strong strong = Strong.new
      @tree.open_scope()
      consume_token(TokenManager::ASTERISK)
      strong_multiline_content()
      while (text_ahead())
        line_break()
        white_space()
        strong_multiline_content()
      end
      consume_token(TokenManager::ASTERISK)
      @tree.close_scope(strong)
    end

    def strong_multiline_content()
      loop do
        if (has_text_ahead())
          text()
        elsif (modules.includes?("images") && has_image_ahead())
          image()
        elsif (modules.includes?("links") && has_link_ahead())
          link()
        elsif (modules.includes?("code") && has_code_ahead())
          code()
        elsif (has_em_within_strong_multiline())
          em_within_strong_multiline()
        else
          case get_next_token_kind()
          when TokenManager::BACKTICK
            @tree.add_single_value(Text.new, consume_token(TokenManager::BACKTICK))
          when TokenManager::LBRACK
            @tree.add_single_value(Text.new, consumeToken(TokenManager::LBRACK))
          when TokenManager::UNDERSCORE
            @tree.add_single_value(Text.new, consumeToken(TokenManager::UNDERSCORE))
          end
        end
      break if !strong_multiline_has_elements_ahead()
      end
    end
  end

  def strong_within_em_multiline()
    Strong strong = Strong.new
    @tree.open_scope()
    consume_token(TokenManager::ASTERISK)
    strong_within_em_multiline_content()
    while (text_ahead())
      line_break()
      strong_within_em_multiline_content()
    end
    consume_token(TokenManager::ASTERISK)
    @tree.close_scope(strong)
  end

  def strong_within_em_multiline_content()
    loop do
      if (has_text_ahead())
        text()
      elsif (modules.includes?("images") && has_image_ahead())
        image()
      elsif (modules.includes?("links") && has_link_ahead())
        link()
      elsif (modules.includes?("code") && has_code_ahead())
        code()
      else
        case get_next_token_kind()
        when TokenManager::BACKTICK
          @tree.add_single_value(Text.new, consume_token(TokenManager::BACKTICK))
        when TokenManager::LBRACK
          @tree.add_single_value(Text.new, consume_token(TokenManager::LBRACK))
        when TokenManager::UNDERSCORE
          @tree.add_single_value(Text.new, consume_token(TokenManager::UNDERSCORE))
        end
      end
      break if !strong_within_em_multiline_has_elements_ahead()
    end
  end

  def strong_within_em()
    strong = Strong.new
    @tree.open_scope()
    consume_token(TokenManager::ASTERISK)
    loop do
      if (has_text_ahead())
        text()
      elsif (modules.includes?("images") && has_image_ahead())
        image()
      elsif (modules.includes?("links") && has_link_ahead())
        link()
      elsif (modules.includes?("code") && has_code_ahead())
        code()
      else
        case get_next_token_kind()
        when TokenManager::BACKTICK
          @tree.add_single_value(Text.new, consume_token(TokenManager::BACKTICK))
        when TokenManager::LBRACK
          @tree.add_single_value(Text.new, consume_token(TokenManager::LBRACK))
        when TokenManager::UNDERSCORE
          @tree.add_single_value(Text.new, consume_token(TokenManager::UNDERSCORE))
        end
      end
      break if !strong_within_em_has_elements_ahead()
    end
    consume_token(TokenManager::ASTERISK)
    @tree.close_scope(strong)
  end

  def em_multiline()
    em = Em.new
    tree.open_scope()
    consume_token(TokenManager::UNDERSCORE)
    em_multiline_content()
    while (text_ahead())
      line_break()
      white_space()
      em_multiline_content()
    end
    consume_token(TokenManager::UNDERSCORE)
    tree.close_scope(em)
  end

  def em_multiline_content()
    loop do
      if (has_text_ahead())
        text()
      elsif (modules.includes?("images") && has_image_ahead())
        image()
      elsif (modules.includes?("links") && has_link_ahead())
        link()
      elsif (modules.includes("code") && multiline_ahead(TokenManager::BACKTICK))
        code_multiline()
      elsif (hasStrongWithinEmMultilineAhead())
        strong_within_em_multiline()
      else
        case get_next_token_kind()
        when TokenManager::ASTERISK
          @tree.add_single_value(Text.new, consume_token(TokenManager::ASTERISK))
        when TokenManager::BACKTICK
          @tree.add_single_value(Text.new, consume_token(TokenManager::BACKTICK))
        when TokenManager::LBRACK
          @tree.add_single_value(Text.new, consume_token(TokenManager::LBRACK))
        end
      end

      break if !em_multiline_content_has_elements_ahead()
    end
  end

  def em_within_strong_multiline()
    em = Em.new
    tree.open_scope()
    consume_token(TokenManager::UNDERSCORE)
    em_within_strong_multiline_content()
    while (text_ahead())
      line_break()
      em_within_strong_multiline_content()
    end
    consume_token(TokenManager::UNDERSCORE)
    tree.close_scope(em)
  end

  def em_within_strong_multiline_content()
    loop do
      if (has_text_ahead())
        text()
      elsif (modules.includes?("images") && has_image_ahead())
        image()
      elsif (modules.includes?("links") && has_link_ahead())
        link()
      elsif (modules.includes("code") && has_code_ahead())
        code()
      else
        case get_next_token_kind()
        when TokenManager::ASTERISK
          @tree.add_single_value(Text.new, consume_token(TokenManager::ASTERISK))
        when TokenManager::BACKTICK
          @tree.add_single_value(Text.new, consume_token(TokenManager::BACKTICK))
        when TokenManager::LBRACK
          @tree.add_single_value(Text.new, consume_token(TokenManager::LBRACK))
        end
      end
      break if em_within_strong_multiline_content_has_elements_ahead()
    end
  end

  def em_within_strong()
    em = Em.new
    @tree.open_scope()
    consume_token(TokenManager::UNDERSCORE)
    loop do
      if (has_text_ahead())
        text()
      elsif (modules.includes?("images") && has_image_ahead())
        image()
      elsif (modules.includes?("links") && has_link_ahead())
        link()
      elsif (modules.includes?("code") && has_code_ahead())
        code()
      else
        case get_next_token_kind()
        when TokenManager::ASTERISK
          @tree.add_single_value(Text.new, consume_token(TokenManager::ASTERISK))
        when TokenManager::BACKTICK
          @tree.add_single_value(Text.new, consume_token(TokenManager::BACKTICK))
        when TokenManager::LBRACK
          @tree.add_single_value(Text.new, consume_token(TokenManager::LBRACK))
        end
      end
      break if !em_within_strong_has_elements_ahead()
    end
    consume_token(TokenManager::UNDERSCORE)
    @tree.close_scope(em)
  end

  def code_multiline()
    code = Code.new
    @tree.openScope()
    consume_token(TokenManager::BACKTICK)
    code_text()
    while (text_ahead())
      line_break()
      white_space()
      while (get_next_token_kind() == TokenManager::GT)
        consume_token(TokenManager::GT)
        white_space()
      end
      code_text()
    end
    consume_token(TokenManager::BACKTICK)
    @tree.close_scope(code)
  end

  def white_space()
    while (get_next_token_kind() == TokenManager::SPACE || get_next_token_kind() == TokenManager::TAB)
      consume_token(get_next_token_kind())
    end
  end

  def has_any_block_elements_ahead()
    begin
      @look_ahead = 1
      @last_position = @scan_position = @token
      return !scan_more_block_elements()
    rescue LookaheadSuccess
      return true
    end
  end

  def block_ahead(block_begin_bolumn)
    quoteLevel = 0

    if (get_next_token_kind() == TokenManager::TokenManager::EOL)
      i = 2
      quoteLevel = 0
      loop do
        quoteLevel = 0
        loop do
          t = get_token(i+=1)
          if (t.kind == TokenManager::GT)
            if (t.beginColumn == 1 && currentBlockLevel > 0 && currentQuoteLevel == 0)
              return false
            end
            quoteLevel+=1
          end
          break if t.kind != TokenManager::GT || t.kind != TokenManager::SPACE || t.kind != TokenManager::TAB
        end
        if (quoteLevel > @currentQuoteLevel)
          return true
        end
        if (quoteLevel < @currentQuoteLevel)
          return false
        end
        break if t.kind != TokenManager::EOL
      end
      return t.kind != TokenManager::EOF && (@current_block_level == 0 || t.begin_column >= block_begin_bolumn + 2)
    end
    return false
  end

  def multiline_ahead(token)
    if (get_next_token_kind() == token && get_token(2).kind != token && get_token(2).kind != TokenManager::EOL)

      loop do
        t = get_token(i)
        if (t.kind == token)
          return true
        elsif (t.kind == TokenManager::TokenManager::EOL)
          i = skip(i + 1, TokenManager::SPACE, TokenManager::TAB)
          quoteLevel = new_quote_level(i)
          if (quoteLevel == @currentQuoteLevel)
            i = skip(i, TokenManager::SPACE, TokenManager::TAB, TokenManager::GT)
            if (getToken(i).kind == token || getToken(i).kind == TokenManager::TokenManager::EOL || getToken(i).kind == TokenManager::DASH \
            || (getToken(i).kind == TokenManager::DIGITS && getToken(i + 1).kind == TokenManager::DOT) \
            || (getToken(i).kind == TokenManager::BACKTICK && getToken(i + 1).kind == TokenManager::BACKTICK && getToken(i + 2).kind == TokenManager::BACKTICK) \
            || headingAhead(i))
              return false
            end
          else
            return false
          end
        elsif (t.kind == EOF)
          return false
        end
      end
    end
    return false
  end

  def fences_ahead()
    i = skip(2, TokenManager::SPACE, TokenManager::TAB, TokenManager::GT)
    if (get_token(i).kind == TokenManager::BACKTICK && get_token(i + 1).kind == TokenManager::BACKTICK && get_token(i + 2).kind == TokenManager::BACKTICK)
      i = skip(i + 3, TokenManager::SPACE, TokenManager::TAB)
      return get_token(i).kind == TokenManager::EOL || get_token(i).kind == TokenManager::EOF
    end
    return false
  end

  def heading_ahead(offset)
    if (get_token(offset).kind == TokenManager::EQ)
      heading = 1

      i = offset + 1
      loop do
        if (get_token(i).kind != TokenManager::EQ)
          return true
        end
        if (heading+=1 > 6)
          return false
        end
        i+= 1
      end
    end
    return false
  end

  def list_item_ahead(list_begin_column, ordered)
    if (get_next_token_kind() == TokenManager::EOL)
      i=2
      eol=1
      loop do
        Token t = getToken(i)
        if (t.kind == TokenManager::EOL && eol+=1 > 2)
          return false
        elsif (t.kind != TokenManager::SPACE && t.kind != TokenManager::TAB && t.kind != TokenManager::GT && t.kind != TokenManager::EOL)
          if (ordered)
            return (t.kind == TokenManager::DIGITS && getToken(i + 1).kind == TokenManager::DOT && t.beginColumn >= list_begin_column)
          end
          return t.kind == TokenManager::DASH && t.beginColumn >= list_begin_column
        end
        i+=1
      end
    end
    return false
  end

  def text_ahead()
    if (get_next_token_kind() == TokenManager::EOL && get_token(2).kind != TokenManager::EOL)
      i = skip(2, TokenManager::SPACE, TokenManager::TAB)
      quote_level = new_quoteLevel(i)
      if (quote_level == @current_quote_level || !@modules.includes?("blockquotes"))
        i = skip(i, TokenManager::SPACE, TokenManager::TAB, TokenManager::GT)

        t = get_token(i)
        return get_token(i).kind != TokenManager::EOL && !(@modules.includes?("lists") && t.kind == TokenManager::DASH) \
        && !(@modules.includes?("lists") && t.kind == TokenManager::DIGITS && getToken(i + 1).kind == TokenManager::DOT) \
        && !(getToken(i).kind == TokenManager::BACKTICK && getToken(i + 1).kind == TokenManager::BACKTICK \
        && getToken(i + 2).kind == TokenManager::BACKTICK) \
        && !(modules.contains("headings") && headingAhead(i))
      end
    end
    return false
  end

  def next_after_space(tokens)
    i = skip(1, TokenManager::SPACE, TokenManager::TAB)
    return tokens.includes?(get_token(i).kind)
  end

  def new_quote_level(offset)
    quote_level = 0
    i = offset
    loop do
      t = get_token(i)
      if (t.kind == TokenManager::GT)
        quoteLevel+=1
      elsif (t.kind != TokenManager::SPACE && t.kind != TokenManager::TAB)
        return quote_level
      end
      i+=1
    end
  end

  def skip(offset, tokens)
    i = offset
    loop do
      t = get_token(i)
      if (!tokens.includes?(t.kind))
        return i
      end
      i+=1
    end
  end

  def has_ordered_list_ahead()
    @lookAhead = 2
    @lastPosition = @scanPosition = @token
    begin
      return !scan_token(TokenManager::DIGITS) && !scan_token(TokenManager::DOT)
    rescue LookaheadSuccess
      return true
    end
  end

  def has_fenced_code_block_ahead()
    @lookAhead = 3
    @lastPosition = @scanPosition = @token
    begin
      return !scan_fenced_code_block()
    rescue LookaheadSuccess
      return true
    end
  end

  def heading_has_inline_elements_ahead()
    @look_ahead = 1
    @last_position = @scan_position = @token
    begin
      xsp = @scan_position
      if (scan_text_tokens())
        @scan_position = xsp
        if (scan_image())
          @scan_position = xsp
          if (scan_link())
            @scan_position = xsp
            if (scan_strong())
              @scan_position = xsp
              if (scan_em())
                @scan_position = xsp
                if (scan_code())
                  @scan_position = xsp
                  if (scan_loose_char())
                    return false
                  end
                end
              end
            end
          end
        end
      end
      return true
    rescue LookaheadSuccess
      return true
    end
  end

  def has_text_ahead()
    @lookAhead = 1
    @lastPosition = @scanPosition = @token
    begin
      return !scan_text_tokens()
    rescue LookaheadSuccess
      return true
    end
  end

  def has_image_ahead()
    @lookAhead = 2147483647
    @lastPosition = @scanPosition = @token
    begin
      return !scan_image()
    rescue LookaheadSuccess
      return true
    end
  end

  def block_quote_has_empty_line_ahead()
    @lookAhead = 2147483647
    @lastPosition = @scanPosition = @token
    begin
      return !scan_block_quote_empty_line()
    rescue LookaheadSuccess
      return true
    end
  end

  def has_strong_ahead()
    @lookAhead = 2147483647
    @lastPosition = @scanPosition = @token
    begin
      return !scan_strong()
    rescue LookaheadSuccess
      return true
    end
  end

  def has_em_ahead()
    @lookAhead = 2147483647
    @lastPosition = @scanPosition = @token
    begin
      return !scan_em()
    rescue LookaheadSuccess
      return true
    end
  end

  def has_code_ahead()
    @lookAhead = 2147483647
    @lastPosition = @scanPosition = @token
    begin
      return !scan_code()
    rescue LookaheadSuccess
      return true
    end
  end

  def block_quote_has_any_block_elementse_ahead()
    @lookAhead = 1
    @lastPosition = @scanPosition = @token
    begin
      return !scan_more_block_elements()
    rescue LookaheadSuccess
      return true
    end
  end

  def has_block_quote_empty_lines_ahead()
    @lookAhead = 2147483647
    @lastPosition = @scanPosition = @token
    begin
      return !scan_block_quote_empty_lines()
    rescue LookaheadSuccess
      return true
    end
  end

  def list_item_has_inline_elements()
    @lookAhead = 1
    @lastPosition = @scanPosition = @token
    begin
      return !scan_more_block_elements()
    rescue LookaheadSuccess
      return true
    end
  end

  def has_inline_text_ahead()
    @lookAhead = 1
    @lastPosition = @scanPosition = @token
    begin
      return !scan_text_tokens()
    rescue LookaheadSuccess
      return true
    end
  end

  def has_inline_element_ahead()
    @lookAhead = 1
    @lastPosition = @scanPosition = @token
    begin
      return !scan_inline_element()
    rescue LookaheadSuccess
      return true
    end
  end

  def image_has_any_elements()
    @lookAhead = 1
    @lastPosition = @scanPosition = @token
    begin
      return !scan_image_element()
    rescue LookaheadSuccess
      return true
    end
  end

  def has_resource_text_ahead()
    @lookAhead = 1
    @lastPosition = @scanPosition = @token
    begin
      return !scan_resource_elements()
    rescue LookaheadSuccess
      return true
    end
  end

  def link_has_any_elements()
    @lookAhead = 1
    @lastPosition = @scanPosition = @token
    begin
      return !scan_link_element()
    rescue LookaheadSuccess
      return true
    end
  end

  def has_resource_url_ahead()
    @lookAhead = 2147483647
    @lastPosition = @scanPosition = @token
    begin
      return !scan_resource_url()
    rescue LookaheadSuccess
      return true
    end
  end

  def resource_has_element_ahead()
    @lookAhead = 2
    @lastPosition = @scanPosition = @token
    begin
      return !scan_resource_element()
    rescue LookaheadSuccess
      return true
    end
  end

  def resource_text_has_elements_ahead()
    @lookAhead = 1
    @lastPosition = @scanPosition = @token
    begin
      return !scan_resource_text_element()
    rescue LookaheadSuccess
      return true
    end
  end

  def has_em_within_strong_multiline()
    @lookAhead = 2147483647
    @lastPosition = @scanPosition = @token
    begin
      return !scan_em_within_strong_multiline()
    rescue LookaheadSuccess
      return true
    end
  end

  def strong_multiline_has_elements_ahead()
    @lookAhead = 1
    @lastPosition = @scanPosition = @token
    begin
      return !scan_strong_multiline_elements()
    rescue LookaheadSuccess
      return true
    end
  end

  def strong_within_em_multiline_has_elements_ahead()
    @lookAhead = 1
    @lastPosition = @scanPosition = @token
    begin
      return !scan_strong_within_em_multiline_elements()
    rescue LookaheadSuccess
      return true
    end
  end

  def has_image()
    @lookAhead = 2147483647
    @lastPosition = @scanPosition = @token
    begin
      return !scan_image()
    rescue LookaheadSuccess
      return true
    end
  end

  def has_link_ahead()
    @lookAhead = 2147483647
    @lastPosition = @scanPosition = @token
    begin
      return !scan_link()
    rescue LookaheadSuccess
      return true
    end
  end

  def strong_em_within_strong_ahead()
    @lookAhead = 2147483647
    @lastPosition = @scanPosition = @token
    begin
      return !scan_em_within_strong()
    rescue LookaheadSuccess
      return true
    end
  end

  def strong_has_elements()
    @lookAhead = 1
    @lastPosition = @scanPosition = @token
    begin
      return !scan_strong_elements()
    rescue LookaheadSuccess
      return true
    end
  end

  def strong_within_em_has_elements_ahead()
    @lookAhead = 1
    @lastPosition = @scanPosition = @token
    begin
      return !scan_strong_within_em_elements()
    rescue LookaheadSuccess
      return true
    end
  end

  def has_strong_within_em_multiline_ahead()
    @lookAhead = 2147483647
    @lastPosition = @scanPosition = @token
    begin
      return !scan_strong_within_em_multiline()
    rescue LookaheadSuccess
      return true
    end
  end

  def em_multiline_content_has_elements_ahead()
    @lookAhead = 1
    @lastPosition = @scanPosition = @token
    begin
      return !scan_em_multiline_content_elements()
    rescue LookaheadSuccess
      return true
    end
  end

  def em_within_strong_multiline_content_has_elements_ahead()
    @lookAhead = 1
    @lastPosition = @scanPosition = @token
    begin
      return !scan_em_within_strong_multilineContent()
    rescue LookaheadSuccess
      return true
    end
  end

  def em_has_strong_within_em()
    @lookAhead = 2147483647
    @lastPosition = @scanPosition = @token
    begin
      return !scan_strong_within_em()
    rescue LookaheadSuccess
      return true
    end
  end

  def em_has_elements()
    @lookAhead = 1
    @lastPosition = @scanPosition = @token
    begin
      return !scan_em_elements()
    rescue LookaheadSuccess
      return true
    end
  end

  def em_within_strong_has_elements_ahead()
    @lookAhead = 1
    @lastPosition = @scanPosition = @token
    begin
      return !scan_em_within_strong_elements()
    rescue LookaheadSuccess
      return true
    end
  end

  def code_text_has_any_token_ahead()
    @lookAhead = 1
    @lastPosition = @scanPosition = @token
    begin
      return !scan_code_text_tokens()
    rescue LookaheadSuccess
      return true
    end
  end

  def text_has_tokens_ahead()
    @lookAhead = 1
    @lastPosition = @scanPosition = @token
    begin
      return !scan_text()
    rescue LookaheadSuccess
      return true
    end
  end

  def scan_loose_char()
    xsp = @scan_position
    if (scan_token(TokenManager::ASTERISK))
      @scan_position = xsp
      if (scan_token(TokenManager::BACKTICK))
        @scan_position = xsp
        if (scan_token(TokenManager::LBRACK))
          @scan_position = xsp
          return scan_token(TokenManager::UNDERSCORE)
        end
      end
    end
    return false
  end

  def scan_text()
    xsp = @scan_position
    if (scan_token(TokenManager::BACKSLASH))
      @scan_position = xsp
      if (scan_token(TokenManager::CHAR_SEQUENCE))
        @scan_position = xsp
        if (scanToken(TokenManager::COLON))
          @scan_position = xsp
          if (scan_token(TokenManager::DASH))
            @scan_position = xsp
            if (scan_token(TokenManager::DIGITS))
              @scan_position = xsp
              if (scan_token(TokenManager::DOT))
                @scan_position = xsp
                if (scan_token(TokenManager::EQ))
                  @scan_position = xsp
                  if (scan_token(TokenManager::ESCAPED_CHAR))
                    @scan_position = xsp
                    if (scan_token(TokenManager::GT))
                      @scan_position = xsp
                      if (scan_token(TokenManager::IMAGE_LABEL))
                        @scan_position = xsp
                        if (scan_token(TokenManager::LPAREN))
                          @scan_position = xsp
                          if (scan_token(TokenManager::LT))
                            @scan_position = xsp
                            if (scan_token(TokenManager::RBRACK))
                              @scan_position = xsp
                              if (scan_token(TokenManager::RPAREN))
                                @scan_Position = xsp
                                looking_ahead = true
                                semantic_look_ahead = !next_after_space(TokenManager::EOL, TokenManager::EOF)
                                return (!semantic_look_ahead || scan_whitspace_token())
                              end
                            end
                          end
                        end
                      end
                    end
                  end
                end
              end
            end
          end
        end
      end
    end
    return false
  end

  def scan_text_tokens()
    if (scan_text())
      return true
    end
    while (true)
      xsp = @scan_position
      if (scan_text())
        @scan_position = xsp
        break
      end
    end
    return false
  end

  def scan_code_text_tokens()
    xsp = @scanPosition
    if (scan_token(TokenManager::ASTERISK))
      @scan_position = xsp
      if (scan_token(TokenManager::BACKSLASH))
        @scan_position = xsp
        if (scan_token(TokenManager::CHAR_SEQUENCE))
          @scan_position = xsp
          if (scan_token(TokenManager::COLON))
            @scan_position = xsp
            if (scan_token(TokenManager::DASH))
              @scan_position = xsp
              if (scan_token(TokenManager::DIGITS))
                @scan_position = xsp
                if (scan_token(TokenManager::DOT))
                  @scan_position = xsp
                  if (scan_token(TokenManager::EQ))
                    @scan_position = xsp
                    if (scan_token(TokenManager::ESCAPED_CHAR))
                      @scan_position = xsp
                      if (scan_token(TokenManager::IMAGE_LABEL))
                        @scan_position = xsp
                        if (scan_token(TokenManager::LT))
                          @scan_position = xsp
                          if (scan_token(TokenManager::LBRACK))
                            @scan_position = xsp
                            if (scanToken(TokenManager::RBRACK))
                              @scan_position = xsp
                              if (scan_token(TokenManager::LPAREN))
                                @scan_position = xsp
                                if (scan_token(TokenManager::GT))
                                  @scan_position = xsp
                                  if (scan_token(TokenManager::RPAREN))
                                    @scan_position = xsp
                                    if (scan_token(TokenManager::UNDERSCORE))
                                      @scan_position = xsp
                                      @looking_ahead = true
                                      @semantic_look_ahead = !next_after_space(TokenManager::EOL, TokenManager::EOF)
                                      @looking_ahead = false
                                      return (!@semantic_look_ahead || scan_whitspace_token())
                                    end
                                  end
                                end
                              end
                            end
                          end
                        end
                      end
                    end
                  end
                end
              end
            end
          end
        end
      end
    end
    return false
  end

  def scan_code()
    return scan_token(TokenManager::BACKTICK) || scan_code_text_tokens_ahead() || scan_token(TokenManager::BACKTICK)
  end

  def scan_code_multiline()
    if (scan_token(TokenManager::BACKTICK) || scan_code_text_tokens_ahead())
      return true
    end
    while (true)
      xsp = @scan_position
      if (has_code_text_on_next_line_ahead())
        @scan_position = xsp
        break
      end
    end
    return scan_token(TokenManager::BACKTICK)
  end

  def scan_code_text_tokens_ahead()
    if (scanCodeTextTokens())
      return true
    end
    while (true)
      xsp = @scan_position
      if (scan_code_text_tokens())
        @scan_position = xsp
        break
      end
    end
    return false
  end

  def has_code_text_on_next_line_ahead()
    if (scan_whitespace_token_before_TokenManager::TokenManager::EOL())
      return true
    end
    while (true)
      xsp = @scan_position
      if (scan_token(TokenManager::GT))
        @scan_position = xsp
        break
      end
    end
    return scan_code_text_tokens_ahead()
  end

  def scan_with_space_tokens()
    while (true)
      xsp = @scan_position
      if (scan_white_space_token())
        @scan_position = xsp
        break
      end
    end
    return false
  end

  def scan_whitespace_token_before_eol()
    return scan_whitspace_tokens() || scan_token(TokenManager::TokenManager::EOL)
  end

  def scan_em_within_strong_elements
    xsp = @scan_position
    if (scan_text_tokens())
      @scan_position = xsp
      if (scan_image())
        @scan_position = xsp
        if (scan_link())
          @scan_position = xsp
          if (scan_code())
            @scan_position = xsp
            if (scan_token(TokenManager::ASTERISK))
              @scan_position = xsp
              if (scan_token(TokenManager::BACKTICK))
                @scan_position = xsp
                return scan_Token(TokenManager::LBRACK)
              end
            end
          end
        end
      end
    end
    return false
  end

  def scan_em_within_strong()
    if (scan_token(TokenManager::UNDERSCORE) || scan_em_within_strong_elements())
      return true
    end
    while (true)
      xsp = @scan_position
      if (scan_em_within_strong_elements())
        @scan_position = xsp
        break
      end
    end
    return scan_token(TokenManager::UNDERSCORE)
  end

  def scan_em_elements()
    xsp = @scan_position
    if (scan_text_tokens())
      @scan_position = xsp
      if (scan_image())
        @scan_position = xsp
        if (scan_link())
          @scan_position = xsp
          if (scan_code())
            @scan_position = xsp
            if (scan_strong_within_em())
              @scan_position = xsp
              if (scan_token(TokenManager::ASTERISK))
                @scan_position = xsp
                if (scan_token(TokenManager::BACKTICK))
                  @scan_position = xsp
                  return scan_token(TokenManager::LBRACK)
                end
              end
            end
          end
        end
      end
    end
    return false
  end

  def scan_em()
    if (scanToken(TokenManager::UNDERSCORE) || scanEmElements())
      return true
    end
    while (true)
      xsp = @scan_position
      if (scan_em_elements())
        @scan_position = xsp
        break
      end
    end
    return scan_token(TokenManager::UNDERSCORE)
  end

  def scan_em_within_strong_multiline_content()
    xsp = @scan_position
    if (scan_text_tokens())
      @scan_position = xsp
      if (scan_image())
        @scan_position = xsp
        if (scan_link())
          @scan_position = xsp
          if (scan_code())
            @scan_position = xsp
            if (scan_token(TokenManager::ASTERISK))
              @scan_position = xsp
              if (scan_token(TokenManager::BACKTICK))
                @scan_position = xsp
                return scan_token(TokenManager::LBRACK)
              end
            end
          end
        end
      end
    end
    return false
  end

  def has_no_em_within_strong_multiline_content_ahead()
    if (scan_em_within_strong_multilineContent())
      return true
    end
    while (true)
      xsp = @scan_position
      if (scan_em_within_strong_multilineContent())
        @scan_position = xsp
        break
      end
    end
    return false
  end

  def scan_em_within_strong_multiline()
    if (scan_token(TokenManager::UNDERSCORE) || has_no_em_within_strong_multiline_content_ahead())
      return true
    end
    while (true)
      xsp = @scan_position
      if (scan_whitespace_token_before_eol() || has_no_em_within_strong_multiline_content_ahead())
        @scan_position = xsp
        break
      end
    end
    return scan_token(TokenManager::UNDERSCORE)
  end

  def scan_em_multiline_content_elements()
    xsp = @scanPosition
    if (scan_text_tokens())
      @scan_position = xsp
      if (scan_image())
        @scan_position = xsp
        if (scan_link())
          @scan_position = xsp
          @looking_ahead = true
          @semantic_lookAhead = multiline_ahead(TokenManager::BACKTICK)
          @looking_ahead = false
          if (!@semantic_look_ahead || scan_code_multiline())
            @scan_position = xsp
            if (scan_strong_within_em_multiline())
              @scan_position = xsp
              if (scan_token(TokenManager::ASTERISK))
                @scan_position = xsp
                if (scan_token(TokenManager::BACKTICK))
                  @scan_position = xsp
                  return scan_token(TokenManager::LBRACK)
                end
              end
            end
          end
        end
      end
    end
    return false
  end

  def scan_strong_within_em_elements()
    xsp = @scan_position
    if (scan_text_tokens())
      @scan_position = xsp
      if (scan_image())
        @scan_position = xsp
        if (scan_link())
          @scan_position = xsp
          if (scan_code())
            @scan_position = xsp
            if (scan_token(TokenManager::BACKTICK))
              @scan_position = xsp
              if (scan_token(TokenManager::LBRACK))
                @scan_position = xsp
                return scan_token(TokenManager::UNDERSCORE)
              end
            end
          end
        end
      end
    end
    return false
  end

  def scan_strong_within_em()
    if (scan_token(TokenManager::ASTERISK) || scan_strong_within_em_elements())
      return true
    end
    while (true)
      xsp = @scan_position
      if (scan_strong_within_em_elements())
        @scan_position = xsp
        break
      end
    end
    return scan_token(TokenManager::ASTERISK)
  end

  def scan_strong_elements()
    xsp = @scan_position
    if (scan_text_tokens())
      @scan_position = xsp
      if (scan_image())
        @scan_position = xsp
        if (scan_link())
          @scan_position = xsp
          @looking_ahead = true
          @semantic_look_ahead = multiline_ahead(TokenManager::BACKTICK)
          @looking_ahead = false
          if (!@semantic_look_ahead || scan_code_multiline())
            @scan_position = xsp
            if (scan_em_within_strong())
              @scan_position = xsp
              if (scan_token(TokenManager::BACKTICK))
                @scan_position = xsp
                if (scan_token(TokenManager::LBRACK))
                  @scan_position = xsp
                  return scan_token(TokenManager::UNDERSCORE)
                end
              end
            end
          end
        end
      end
    end
    return false
  end

  def scan_strong()
    if (scan_token(TokenManager::ASTERISK) || scan_strong_elements())
      return true
    end
    while (true)
      xsp = @scan_position
      if (scan_strong_elements())
        @scan_position = xsp
        break
      end
    end
    return scan_token(TokenManager::ASTERISK)
  end

  def scan_strong_within_em_multiline_elements()
    xsp = @scanPosition
    if (scan_text_tokens())
      @scan_position = xsp
      if (scan_image())
        @scan_position = xsp
        if (scan_link())
          @scan_position = xsp
          if (scan_code())
            @scan_position = xsp
            if (scan_token(TokenManager::BACKTICK))
              @scan_position = xsp
              if (scan_token(TokenManager::LBRACK))
                @scan_position = xsp
                return scan_token(TokenManager::UNDERSCORE)
              end
            end
          end
        end
      end
    end
    return false
  end

  def scan_for_more_strong_within_em_multiline_elements()
    if (scanStrongWithinEmMultilineElements())
      return true
    end
    loop do
      xsp = @scan_position
      if (scan_strong_within_em_multiline_elements())
        @scan_position = xsp
        break
      end
    end
    return false
  end

  def scan_strong_within_em_multiline()
    if (scan_token(TokenManager::ASTERISK) || scan_for_more_strong_within_em_multiline_elements())
      return true
    end
    while (true)
      xsp = scanPosition
      if (scan_whitespace_token_before_eol() || scan_for_more_strong_within_em_multiline_elements())
        @scan_position = xsp
        break
      end
    end
    return scan_token(TokenManager::ASTERISK)
  end

  def scan_strong_multiline_elements()
    xsp = @scanPosition
    if (scan_text_tokens())
      @scan_position = xsp
      if (scan_image())
        @scan_position = xsp
        if (scan_link())
          @scan_position = xsp
          if (scan_code())
            @scan_position = xsp
            if (scan_em_within_strong_multiline())
              @scan_position = xsp
              if (scan_token(TokenManager::BACKTICK))
                @scan_position = xsp
                if (scan_token(TokenManager::LBRACK))
                  @scan_position = xsp
                  return scan_token(TokenManager::UNDERSCORE)
                end
              end
            end
          end
        end
      end
    end
    return false
  end

  def scan_resource_text_element()
    xsp = @scanPosition
    if (scan_token(TokenManager::ASTERISK))
      @scan_position = xsp
      if (scan_token(TokenManager::BACKSLASH))
        @scan_position = xsp
        if (scan_token(TokenManager::BACKTICK))
          @scan_position = xsp
          if (scan_token(TokenManager::CHAR_SEQUENCE))
            @scan_position = xsp
            if (scan_token(TokenManager::COLON))
              @scan_position = xsp
              if (scan_token(TokenManager::DASH))
                @scan_position = xsp
                if (scan_token(TokenManager::DIGITS))
                  @scan_position = xsp
                  if (scan_token(TokenManager::DOT))
                    @scan_position = xsp
                    if (scan_token(TokenManager::EQ))
                      @scan_position = xsp
                      if (scan_token(TokenManager::ESCAPED_CHAR))
                        @scan_position = xsp
                        if (scan_token(TokenManager::IMAGE_LABEL))
                          @scan_position = xsp
                          if (scan_token(TokenManager::GT))
                            @scan_position = xsp
                            if (scan_token(TokenManager::LBRACK))
                              @scan_position = xsp
                              if (scan_token(TokenManager::LPAREN))
                                @scan_position = xsp
                                if (scan_token(TokenManager::LT))
                                  @scan_position = xsp
                                  if (scan_token(TokenManager::RBRACK))
                                    @scan_position = xsp
                                    if (scan_token(TokenManager::UNDERSCORE))
                                      @scan_position = xsp
                                      @looking_ahead = true
                                      @semantic_look_ahead = !next_after_space(TokenManager::RPAREN)
                                      @looking_ahead = false
                                      return (!@semantic_look_ahead || scan_whitspace_token())
                                    end
                                  end
                                end
                              end
                            end
                          end
                        end
                      end
                    end
                  end
                end
              end
            end
          end
        end
      end
    end
    return false
  end

  def scan_image_element()
    xsp = @scanPosition
    if (scan_resource_elements())
      @scan_position = xsp
      if (scan_loose_char())
        return true
      end
    end
    return false
  end

  def scan_resource_text_elements()
    while (true)
      xsp = @scan_position
      if (scan_resource_text_element())
        @scan_position = xsp
        break
      end
    end
    return false
  end

  def scan_resource_url()
    return scan_token(TokenManager::LPAREN) || scan_whitspace_tokens() || scan_resource_text_elements() || scan_whitspace_tokens() || scan_token(TokenManager::RPAREN)
  end

  def scan_link_element()
    xsp = @scan_position
    if (scan_image())
      @scan_position = xsp
      if (scan_strong())
        @scan_position = xsp
        if (scan_em())
          @scan_position = xsp
          if (scan_code())
            @scan_position = xsp
            if (scan_resource_elements())
              @scan_position = xsp
              return scan_loose_char()
            end
          end
        end
      end
    end
    return false
  end

  def scan_resource_element()
    xsp = @scan_position
    if (scan_token(TokenManager::BACKSLASH))
      @scan_position = xsp
      if (scan_token(TokenManager::COLON))
        @scan_position = xsp
        if (scan_token(TokenManager::CHAR_SEQUENCE))
          @scan_position = xsp
          if (scan_token(TokenManager::DASH))
            @scan_position = xsp
            if (scan_token(TokenManager::DIGITS))
              @scan_position = xsp
              if (scan_token(TokenManager::DOT))
                @scan_position = xsp
                if (scan_token(TokenManager::EQ))
                  @scan_position = xsp
                  if (scanToken(TokenManager::ESCAPED_CHAR))
                    @scanPosition = xsp
                    if (scan_token(TokenManager::IMAGE_LABEL))
                      @scan_position = xsp
                      if (scan_token(TokenManager::GT))
                        @scan_position = xsp
                        if (scan_token(TokenManager::LPAREN))
                          @scan_position = xsp
                          if (scan_token(TokenManager::LT))
                            @scan_position = xsp
                            if (scan_token(TokenManager::RPAREN))
                              @scan_position = xsp
                              @looking_ahead = true
                              @semantic_look_ahead = !next_after_space(TokenManager::RBRACK)
                              @looking_ahead = false
                              return (!semantic_look_ahead || scan_whitspace_token())
                            end
                          end
                        end
                      end
                    end
                  end
                end
              end
            end
          end
        end
      end
    end
    return false
  end

  def scan_resource_elements()
    if (scan_resource_element())
      return true
    end
    loop do
      xsp = @scan_position
      if (scan_resource_element())
        @scan_position = xsp
        break
      end
    end
    return false
  end

  def scan_link()
    if (scan_token(TokenManager::LBRACK) || scan_whitspace_tokens() || scan_link_element())
      return true
    end
    while (true)
      xsp = @scan_position
      if (scan_link_element())
        @scan_position = xsp
        break
      end
    end
    if (scan_white_space_tokens() || scan_token(TokenManager::RBRACK))
      return true
    end
    xsp = @scan_position
    if (scan_resource_url())
      @scan_position = xsp
    end
    return false
  end

  def scan_image()
    if (scan_token(TokenManager::LBRACK) || scan_whitspace_tokens() || scan_token(TokenManager::IMAGE_LABEL) || scan_image_element())
      return true
    end
    while (true)
      xsp = @scan_position
      if (scanImageElement())
        @scan_position = xsp
        break
      end
    end
    if (scan_white_space_tokens() || scan_token(TokenManager::RBRACK))
      return true
    end
    xsp = @scan_position
    if (scan_resource_url())
      @scan_position = xsp
    end
    return false
  end

  def scan_inline_element()
    xsp = @scanPosition
    if (scan_text_tokens())
      @scan_position = xsp
      if (scan_image())
        @scan_position = xsp
        if (scan_link())
          @scan_position = xsp
          @looking_ahead = true
          @semantic_look_ahead = multiline_ahead(TokenManager::ASTERISK)
          @looking_ahead = false
          if (!semantic_look_ahead || scan_token(TokenManager::ASTERISK))
            @scan_position = xsp
            @looking_ahead = true
            @semantic_look_ahead = multiline_ahead(TokenManager::UNDERSCORE)
            @looking_ahead = false
            if (!semantic_look_ahead || scan_token(TokenManager::UNDERSCORE))
              @scan_position = xsp
              @looking_ahead = true
              @semantic_look_ahead = multiline_ahead(TokenManager::BACKTICK)
              @looking_ahead = false
              if (!@semantic_look_ahead || scan_code_multiline())
                @scan_position = xsp
                return scan_loose_char()
              end
            end
          end
        end
      end
    end
    return false
  end

  def scan_paragraph()
    if (scan_inline_element())
      return true
    end
    while (true)
      xsp = @scan_position
      if (scan_inline_element())
        @scan_position = xsp
        break
      end
    end
    return false
  end

  def scan_whitspace_token()
    xsp = @scan_position
    if (scan_token(TokenManager::SPACE))
      @scan_position = xsp
      if (scan_token(TokenManager::TAB))
        return true
      end
    end
    return false
  end

  def scan_fenced_code_block()
    return scan_token(TokenManager::BACKTICK) || scan_token(TokenManager::BACKTICK) || scan_token(TokenManager::BACKTICK)
  end

  def scan_block_quote_empty_lines()
    return scan_block_quote_empty_line() || scanToken(TokenManager::TokenManager::EOL)
  end

  def scan_block_quote_empty_line()
    if (scan_token(TokenManager::TokenManager::EOL) || scan_whitspace_tokens() || scan_token(TokenManager::GT) || scan_whitspace_tokens())
      return true
    end
    while (true)
      xsp = @scan_position
      if (scan_token(TokenManager::GT) || scan_white_space_tokens())
        @scan_position = xsp
        break
      end
    end
    return false
  end

  def scan_for_headersigns()
    if (scan_token(TokenManager::EQ))
      return true
    end
    while (true)
      xsp = @scan_position
      if (scan_token(TokenManager::EQ))
        @scan_position = xsp
        break
      end
    end
    return false
  end

  def scan_more_block_elements()
    xsp = @scanPosition
    @lookingAhead = true
    @semanticLookAhead = heading_ahead(1)
    @lookingAhead = false
    if (!semantic_lookAhead || scan_for_headersigns())
      @scan_position = xsp
      if (scan_token(TokenManager::GT))
        @scan_position = xsp
        if (scan_token(TokenManager::DASH))
          @scan_position = xsp
          if (scan_token(TokenManager::DIGITS) || scan_token(TokenManager::DOT))
            @scan_position = xsp
            if (scan_fenced_code_block())
              @scan_position = xsp
              return scan_paragraph()
            end
          end
        end
      end
    end
    return false
  end

  def scan_token(kind)
    if (@scan_position == @last_position)
      @look_ahead -= 1
      if (@scan_position.next.nil?)
        @last_position = @scan_position = @scan_position.next = @tm.get_next_token()
      else
        @last_position = @scan_position = @scan_position.next
      end
    else
      @scan_position = @scan_position.next
    end
    if (@scan_position.kind != kind)
      return true
    end
    if (@look_ahead == 0 && @scan_position == @last_position)
      raise @look_ahead_success
    end
    return false
  end

  def get_next_token_kind()
    if (@next_token_kind != -1)
      return @next_token_kind
    elsif ((@next_token = @token.next).nil?)
      @token.next = @tm.get_next_token()
      return (@next_token_kind = @token.next.kind)
    end
    return (@next_token_kind = @next_token.kind)
  end

  def consume_token(kind)
    old = @token
    if (@token.next.nil?)
      @token = @token.next
    else
      @token = @token.next = @tm.get_next_token()
    end
    @next_token_kind = -1
    if (@token.kind == kind)
      return token
    end
    @token = old
    return @token
  end

  def get_token(index)
    
    t = @looking_ahead ? @scan_position : @token
    0.upto(index - 1) do |i|
      if(!t.next.nil?)
        t = t.next
      else
        t = t.next = @tm.get_next_token()
      end
    end
    return t
  end

  def modules=(*modules)
    @modules = modules.to_a
  end

end
