require_relative 'charstream'
require_relative 'lookahead_success'
require_relative 'token'
require_relative 'token_manager'
require_relative 'tree_state'

class Parser
  attr_reader :modules
  #    private CharStream cs
  #    private Token token, nextToken, scanPosition, lastPosition
  #    private TokenManager tm
  #    private TreeState tree
  #    private int currentBlockLevel
  #    private int currentQuoteLevel
  #    private int lookAhead
  #    private int nextTokenKind
  #    private boolean lookingAhead
  #    private boolean semanticLookAhead
  #    private LookaheadSuccess lookAheadSuccess
  #
  def initialize()
    @lookAheadSuccess = LookaheadSuccess.new
    @modules = ["paragraphs", "headings", "lists", "links", "images", "formatting", "blockquotes", "code"]
  end

  def parse(text)
    return parse_reader(text)
  end

  def parse_file(file)
    #      if(!file.getName().toLowerCase().endsWith(".kd")) {
    #        throw new IllegalArgumentException("Can only parse files with extension .kd")
    #      }
    #      return parse_reader(new FileReader(file))
  end

  def parse_reader(reader)
    @cs =  CharStream.new(reader)
    @tm =  TokenManager.new(@cs)
    @token =  Token.new
    @tree = TreeState.new()
    @nextTokenKind = -1
    document = Document.new()
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

  #
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
    heading =  Heading.new()
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
    blockquote = BlockQuote.new()
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
    #        do {
    consume_token(TokenManager::GT)
    white_space()
    #        } while (++i < currentQuoteLevel)
  end

  def block_quote_empty_line()
    consume_token(TokenManager::TokenManager::EOL)
    white_space()
    #        do {
    consume_token(TokenManager::GT)
    white_space()
    #        } while (getNextTokenKind() == TokenManager::GT)
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
    listItem = ListItem.new()
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
    list_item = ListItem.new()
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
    code_block = CodeBlock.new()
    @tree.open_scope()
    #        StringBuilder s = new StringBuilder()
    begin_column = consume_token(TokenManager::BACKTICK).begin_column
    #        do {
    #            consumeToken(TokenManager::BACKTICK)
    #        } while (getNextTokenKind() == TokenManager::BACKTICK)
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
      #            switch (kind) {
      #          case TokenManager::CHAR_STokenManager::EQUENCE:
      #            s.append(consumeToken(TokenManager::CHAR_STokenManager::EQUENCE).image)
      #            break
      #            case TokenManager::ASTERISK:
      #                s.append(consumeToken(TokenManager::ASTERISK).image)
      #                break
      #            case TokenManager::BACKSLASH:
      #                s.append(consumeToken(TokenManager::BACKSLASH).image)
      #                break
      #            case TokenManager::COLON:
      #                s.append(consumeToken(TokenManager::COLON).image)
      #                break
      #            case TokenManager::DASH:
      #                s.append(consumeToken(TokenManager::DASH).image)
      #                break
      #            case TokenManager::DIGITS:
      #                s.append(consumeToken(TokenManager::DIGITS).image)
      #                break
      #            case TokenManager::DOT:
      #                s.append(consumeToken(TokenManager::DOT).image)
      #                break
      #            case TokenManager::EQ:
      #                s.append(consumeToken(TokenManager::EQ).image)
      #                break
      #            case TokenManager::ESCAPED_CHAR:
      #                s.append(consumeToken(TokenManager::ESCAPED_CHAR).image)
      #                break
      #            case TokenManager::IMAGE_LABEL:
      #                s.append(consumeToken(TokenManager::IMAGE_LABEL).image)
      #                break
      #            case TokenManager::LT:
      #                s.append(consumeToken(TokenManager::LT).image)
      #                break
      #            case TokenManager::GT:
      #                s.append(consumeToken(TokenManager::GT).image)
      #                break
      #            case TokenManager::LBRACK:
      #                s.append(consumeToken(TokenManager::LBRACK).image)
      #                break
      #            case TokenManager::RBRACK:
      #                s.append(consumeToken(TokenManager::RBRACK).image)
      #                break
      #            case TokenManager::LPAREN:
      #                s.append(consumeToken(TokenManager::LPAREN).image)
      #                break
      #            case TokenManager::RPAREN:
      #                s.append(consumeToken(TokenManager::RPAREN).image)
      #                break
      #            case TokenManager::UNDERSCORE:
      #                s.append(consumeToken(TokenManager::UNDERSCORE).image)
      #                break
      #            case TokenManager::BACKTICK:
      #                s.append(consumeToken(TokenManager::BACKTICK).image)
      #                break
      #            default:
      #                if (!nextAfterspace(TokenManager::TokenManager::EOL, EOF)) {
      #                    switch (kind) {
      #                    case TokenManager::SPACE:
      #                        s.append(consumeToken(TokenManager::SPACE).image)
      #                        break
      #                    case TokenManager::TAB:
      #                        consumeToken(TokenManager::TAB)
      #                        s.append("    ")
      #                        break
      #                    }
      #                } else if (!fencesAhead()) {
      #                    consumeToken(TokenManager::TokenManager::EOL)
      #                    s.append("\n")
      #                    levelWhitespace(beginColumn)
      #                }
      #            }
      #            kind = getNextTokenKind()
    end
    if (fences_ahead())
      consume_token(TokenManager::TokenManager::EOL)
      white_space()
      while (get_next_token_kind() == TokenManager::BACKTICK)
        consume_token(TokenManager::BACKTICK)
      end
    end
    #        codeBlock.setValue(s.toString())
    @tree.close_scope(code_block)
  end

  def paragraph()
    paragraph = modules.includes?("paragraphs") ? Paragraph.new() : BlockElement.new()
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
    text = Text.new()
    @tree.open_scope()
    #        StringBuffer s = new StringBuffer()
    while (text_has_tokens_ahead())
      #            switch (getNextTokenKind()) {
      #          case TokenManager::CHAR_STokenManager::EQUENCE:
      #            s.append(consumeToken(TokenManager::CHAR_STokenManager::EQUENCE).image)
      #            break
      #            case TokenManager::BACKSLASH:
      #                s.append(consumeToken(TokenManager::BACKSLASH).image)
      #                break
      #            case TokenManager::COLON:
      #                s.append(consumeToken(TokenManager::COLON).image)
      #                break
      #            case TokenManager::DASH:
      #                s.append(consumeToken(TokenManager::DASH).image)
      #                break
      #            case TokenManager::DIGITS:
      #                s.append(consumeToken(TokenManager::DIGITS).image)
      #                break
      #            case TokenManager::DOT:
      #                s.append(consumeToken(TokenManager::DOT).image)
      #                break
      #            case TokenManager::EQ:
      #                s.append(consumeToken(TokenManager::EQ).image)
      #                break
      #            case TokenManager::ESCAPED_CHAR:
      #                s.append(consumeToken(TokenManager::ESCAPED_CHAR).image.substring(1))
      #                break
      #            case TokenManager::GT:
      #                s.append(consumeToken(TokenManager::GT).image)
      #                break
      #            case TokenManager::IMAGE_LABEL:
      #                s.append(consumeToken(TokenManager::IMAGE_LABEL).image)
      #                break
      #            case TokenManager::LPAREN:
      #                s.append(consumeToken(TokenManager::LPAREN).image)
      #                break
      #            case TokenManager::LT:
      #                s.append(consumeToken(TokenManager::LT).image)
      #                break
      #            case TokenManager::RBRACK:
      #                s.append(consumeToken(TokenManager::RBRACK).image)
      #                break
      #            case TokenManager::RPAREN:
      #                s.append(consumeToken(TokenManager::RPAREN).image)
      #                break
      #            default:
      #                if (!nextAfterspace(TokenManager::TokenManager::EOL, EOF)) {
      #                    switch (getNextTokenKind()) {
      #                    case TokenManager::SPACE:
      #                        s.append(consumeToken(TokenManager::SPACE).image)
      #                        break
      #                    case TokenManager::TAB:
      #                        consumeToken(TokenManager::TAB)
      #                        s.append("    ")
      #                        break
      #                    }
      #                }
      #            }
    end
    #        text.setValue(s.toString())
    @tree.close_scope(text)
  end

  def image()
    image = Image.new()
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
    link = Link.new()
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
    strong = Strong.new()
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
        #                switch (getNextTokenKind()) {
        #                case TokenManager::BACKTICK:
        #                    tree.addSingleValue(new Text(), consumeToken(TokenManager::BACKTICK))
        #                    break
        #                case TokenManager::LBRACK:
        #                    tree.addSingleValue(new Text(), consumeToken(TokenManager::LBRACK))
        #                    break
        #                case TokenManager::UNDERSCORE:
        #                    tree.addSingleValue(new Text(), consumeToken(TokenManager::UNDERSCORE))
        #                    break
        #                }
      end
    end
    consume_token(TokenManager::ASTERISK)
    @tree.close_scope(strong)
  end

  def em()
    em = Em.new()
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
        #                switch (getNextTokenKind()) {
        #                case TokenManager::ASTERISK:
        #                    tree.addSingleValue(new Text(), consumeToken(TokenManager::ASTERISK))
        #                    break
        #                case TokenManager::BACKTICK:
        #                    tree.addSingleValue(new Text(), consumeToken(TokenManager::BACKTICK))
        #                    break
        #                case TokenManager::LBRACK:
        #                    tree.addSingleValue(new Text(), consumeToken(TokenManager::LBRACK))
        #                    break
        #                }
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
    text = Text.new()
    @tree.open_scope()
    #        StringBuffer s = new StringBuffer()
    #        do {
    #            switch (getNextTokenKind()) {
    #          case TokenManager::CHAR_STokenManager::EQUENCE:
    #            s.append(consumeToken(TokenManager::CHAR_STokenManager::EQUENCE).image)
    #            break
    #            case TokenManager::ASTERISK:
    #                s.append(consumeToken(TokenManager::ASTERISK).image)
    #                break
    #            case TokenManager::BACKSLASH:
    #                s.append(consumeToken(TokenManager::BACKSLASH).image)
    #                break
    #            case TokenManager::COLON:
    #                s.append(consumeToken(TokenManager::COLON).image)
    #                break
    #            case TokenManager::DASH:
    #                s.append(consumeToken(TokenManager::DASH).image)
    #                break
    #            case TokenManager::DIGITS:
    #                s.append(consumeToken(TokenManager::DIGITS).image)
    #                break
    #            case TokenManager::DOT:
    #                s.append(consumeToken(TokenManager::DOT).image)
    #                break
    #            case TokenManager::EQ:
    #                s.append(consumeToken(TokenManager::EQ).image)
    #                break
    #            case TokenManager::ESCAPED_CHAR:
    #                s.append(consumeToken(TokenManager::ESCAPED_CHAR).image)
    #                break
    #            case TokenManager::IMAGE_LABEL:
    #                s.append(consumeToken(TokenManager::IMAGE_LABEL).image)
    #                break
    #            case TokenManager::LT:
    #                s.append(consumeToken(TokenManager::LT).image)
    #                break
    #            case TokenManager::LBRACK:
    #                s.append(consumeToken(TokenManager::LBRACK).image)
    #                break
    #            case TokenManager::RBRACK:
    #                s.append(consumeToken(TokenManager::RBRACK).image)
    #                break
    #            case TokenManager::LPAREN:
    #                s.append(consumeToken(TokenManager::LPAREN).image)
    #                break
    #            case TokenManager::GT:
    #                s.append(consumeToken(TokenManager::GT).image)
    #                break
    #            case TokenManager::RPAREN:
    #                s.append(consumeToken(TokenManager::RPAREN).image)
    #                break
    #            case TokenManager::UNDERSCORE:
    #                s.append(consumeToken(TokenManager::UNDERSCORE).image)
    #                break
    #            default:
    #                if (!nextAfterspace(TokenManager::TokenManager::EOL, EOF)) {
    #                    switch (getNextTokenKind()) {
    #                    case TokenManager::SPACE:
    #                        s.append(consumeToken(TokenManager::SPACE).image)
    #                        break
    #                    case TokenManager::TAB:
    #                        consumeToken(TokenManager::TAB)
    #                        s.append("    ")
    #                        break
    #                    }
    #                }
    #            }
    #        } while (codeTextHasAnyTokenAhead())
    #        text.setValue(s.toString())
    @tree.close_scope(text)
  end

  def loose_char()
    text = Text.new()
    @tree.open_scope()
    #        switch (getNextTokenKind()) {
    #        case TokenManager::ASTERISK:
    #            text.setValue(consumeToken(TokenManager::ASTERISK).image)
    #            break
    #        case TokenManager::BACKTICK:
    #            text.setValue(consumeToken(TokenManager::BACKTICK).image)
    #            break
    #        case TokenManager::LBRACK:
    #            text.setValue(consumeToken(TokenManager::LBRACK).image)
    #            break
    #        case TokenManager::UNDERSCORE:
    #            text.setValue(consumeToken(TokenManager::UNDERSCORE).image)
    #            break
    #        }
    @tree.close_scope(text)
  end

  def line_break()
    linebreak = LineBreak.new()
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
    #        StringBuilder s = new StringBuilder()
    #        do {
    #            switch (getNextTokenKind()) {
    #          case TokenManager::CHAR_STokenManager::EQUENCE:
    #            s.append(consumeToken(TokenManager::CHAR_STokenManager::EQUENCE).image)
    #            break
    #            case TokenManager::ASTERISK:
    #                s.append(consumeToken(TokenManager::ASTERISK).image)
    #                break
    #            case TokenManager::BACKSLASH:
    #                s.append(consumeToken(TokenManager::BACKSLASH).image)
    #                break
    #            case TokenManager::BACKTICK:
    #                s.append(consumeToken(TokenManager::BACKTICK).image)
    #                break
    #            case TokenManager::COLON:
    #                s.append(consumeToken(TokenManager::COLON).image)
    #                break
    #            case TokenManager::DASH:
    #                s.append(consumeToken(TokenManager::DASH).image)
    #                break
    #            case TokenManager::DIGITS:
    #                s.append(consumeToken(TokenManager::DIGITS).image)
    #                break
    #            case TokenManager::DOT:
    #                s.append(consumeToken(TokenManager::DOT).image)
    #                break
    #            case TokenManager::EQ:
    #                s.append(consumeToken(TokenManager::EQ).image)
    #                break
    #            case TokenManager::ESCAPED_CHAR:
    #                s.append(consumeToken(TokenManager::ESCAPED_CHAR).image)
    #                break
    #            case TokenManager::IMAGE_LABEL:
    #                s.append(consumeToken(TokenManager::IMAGE_LABEL).image)
    #                break
    #            case TokenManager::LT:
    #                s.append(consumeToken(TokenManager::LT).image)
    #                break
    #            case TokenManager::GT:
    #                s.append(consumeToken(TokenManager::GT).image)
    #                break
    #            case TokenManager::LBRACK:
    #                s.append(consumeToken(TokenManager::LBRACK).image)
    #                break
    #            case TokenManager::RBRACK:
    #                s.append(consumeToken(TokenManager::RBRACK).image)
    #                break
    #            case TokenManager::LPAREN:
    #                s.append(consumeToken(TokenManager::LPAREN).image)
    #                break
    #            case TokenManager::RPAREN:
    #                s.append(consumeToken(TokenManager::RPAREN).image)
    #                break
    #            case TokenManager::UNDERSCORE:
    #                s.append(consumeToken(TokenManager::UNDERSCORE).image)
    #                break
    #            case TokenManager::SPACE:
    #                s.append(consumeToken(TokenManager::SPACE).image)
    #                break
    #            case TokenManager::TAB:
    #                s.append("    ")
    #                break
    #            default:
    #                break
    #            }
    #        } while (getNextTokenKind() != TokenManager::TokenManager::EOL && getNextTokenKind() != EOF)
    #        return s.toString()
  end

  def inline()
    #        do {
    #            if (hasInlineTextAhead()) {
    #                text()
    #            } else if (modules.contains("images") && hasImageAhead()) {
    #                image()
    #            } else if (modules.contains("links") && hasLinkAhead()) {
    #                link()
    #            } else if (modules.contains("formatting") && multilineAhead(TokenManager::ASTERISK)) {
    #                strongMultiline()
    #            } else if (modules.contains("formatting") && multilineAhead(TokenManager::UNDERSCORE)) {
    #                emMultiline()
    #            } else if (modules.contains("code") && multilineAhead(TokenManager::BACKTICK)) {
    #                codeMultiline()
    #            } else {
    #                looseChar()
    #            }
    #        } while (hasInlineElementAhead())
  end

  def resource_text()
    text = Text.new()
    tree.open_scope()
    #        StringBuilder s = new StringBuilder()
    #        do {
    #            switch (getNextTokenKind()) {
    #          case TokenManager::CHAR_STokenManager::EQUENCE:
    #            s.append(consumeToken(TokenManager::CHAR_STokenManager::EQUENCE).image)
    #            break
    #            case TokenManager::BACKSLASH:
    #                s.append(consumeToken(TokenManager::BACKSLASH).image)
    #                break
    #            case TokenManager::COLON:
    #                s.append(consumeToken(TokenManager::COLON).image)
    #                break
    #            case TokenManager::DASH:
    #                s.append(consumeToken(TokenManager::DASH).image)
    #                break
    #            case TokenManager::DIGITS:
    #                s.append(consumeToken(TokenManager::DIGITS).image)
    #                break
    #            case TokenManager::DOT:
    #                s.append(consumeToken(TokenManager::DOT).image)
    #                break
    #            case TokenManager::EQ:
    #                s.append(consumeToken(TokenManager::EQ).image)
    #                break
    #            case TokenManager::ESCAPED_CHAR:
    #                s.append(consumeToken(TokenManager::ESCAPED_CHAR).image.substring(1))
    #                break
    #            case TokenManager::IMAGE_LABEL:
    #                s.append(consumeToken(TokenManager::IMAGE_LABEL).image)
    #                break
    #            case TokenManager::GT:
    #                s.append(consumeToken(TokenManager::GT).image)
    #                break
    #            case TokenManager::LPAREN:
    #                s.append(consumeToken(TokenManager::LPAREN).image)
    #                break
    #            case TokenManager::LT:
    #                s.append(consumeToken(TokenManager::LT).image)
    #                break
    #            case TokenManager::RPAREN:
    #                s.append(consumeToken(TokenManager::RPAREN).image)
    #                break
    #            default:
    #                if (!nextAfterspace(TokenManager::RBRACK)) {
    #                    switch (getNextTokenKind()) {
    #                    case TokenManager::SPACE:
    #                        s.append(consumeToken(TokenManager::SPACE).image)
    #                        break
    #                    case TokenManager::TAB:
    #                        consumeToken(TokenManager::TAB)
    #                        s.append("    ")
    #                        break
    #                    }
    #                }
    #            }
    #        } while (resourceHasElementAhead())
    #        text.setValue(s.toString())
    tree.close_scope(text)
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
    #        StringBuilder s = new StringBuilder()
    #        while (resourceTextHasElementsAhead()) {
    #            switch (getNextTokenKind()) {
    #          case TokenManager::CHAR_STokenManager::EQUENCE:
    #            s.append(consumeToken(TokenManager::CHAR_STokenManager::EQUENCE).image)
    #            break
    #            case TokenManager::ASTERISK:
    #                s.append(consumeToken(TokenManager::ASTERISK).image)
    #                break
    #            case TokenManager::BACKSLASH:
    #                s.append(consumeToken(TokenManager::BACKSLASH).image)
    #                break
    #            case TokenManager::BACKTICK:
    #                s.append(consumeToken(TokenManager::BACKTICK).image)
    #                break
    #            case TokenManager::COLON:
    #                s.append(consumeToken(TokenManager::COLON).image)
    #                break
    #            case TokenManager::DASH:
    #                s.append(consumeToken(TokenManager::DASH).image)
    #                break
    #            case TokenManager::DIGITS:
    #                s.append(consumeToken(TokenManager::DIGITS).image)
    #                break
    #            case TokenManager::DOT:
    #                s.append(consumeToken(TokenManager::DOT).image)
    #                break
    #            case TokenManager::EQ:
    #                s.append(consumeToken(TokenManager::EQ).image)
    #                break
    #            case TokenManager::ESCAPED_CHAR:
    #                s.append(consumeToken(TokenManager::ESCAPED_CHAR).image.substring(1))
    #                break
    #            case TokenManager::IMAGE_LABEL:
    #                s.append(consumeToken(TokenManager::IMAGE_LABEL).image)
    #                break
    #            case TokenManager::GT:
    #                s.append(consumeToken(TokenManager::GT).image)
    #                break
    #            case TokenManager::LBRACK:
    #                s.append(consumeToken(TokenManager::LBRACK).image)
    #                break
    #            case TokenManager::LPAREN:
    #                s.append(consumeToken(TokenManager::LPAREN).image)
    #                break
    #            case TokenManager::LT:
    #                s.append(consumeToken(TokenManager::LT).image)
    #                break
    #            case TokenManager::RBRACK:
    #                s.append(consumeToken(TokenManager::RBRACK).image)
    #                break
    #            case TokenManager::UNDERSCORE:
    #                s.append(consumeToken(TokenManager::UNDERSCORE).image)
    #                break
    #            default:
    #                if (!nextAfterspace(TokenManager::RPAREN)) {
    #                    switch (getNextTokenKind()) {
    #                    case TokenManager::SPACE:
    #                        s.append(consumeToken(TokenManager::SPACE).image)
    #                        break
    #                    case TokenManager::TAB:
    #                        consumeToken(TokenManager::TAB)
    #                        s.append("    ")
    #                        break
    #                    }
    #                }
    #            }
    #        }
    #        return s.toString()
  end

  def strong_multiline()
    Strong strong = Strong.new()
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
    #        do {
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
      #                switch (getNextTokenKind()) {
      #                case TokenManager::BACKTICK:
      #                    tree.addSingleValue(new Text(), consumeToken(TokenManager::BACKTICK))
      #                    break
      #                case TokenManager::LBRACK:
      #                    tree.addSingleValue(new Text(), consumeToken(TokenManager::LBRACK))
      #                    break
      #                case TokenManager::UNDERSCORE:
      #                    tree.addSingleValue(new Text(), consumeToken(TokenManager::UNDERSCORE))
      #                    break
      #                }
    end
    #        } while (strongMultilineHasElementsAhead())
  end

  def strong_within_em_multiline()
    Strong strong = Strong.new()
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
    #        do {
    if (has_text_ahead())
      text()
    elsif (modules.includes?("images") && has_image_ahead())
      image()
    elsif (modules.includes?("links") && has_link_ahead())
      link()
    elsif (modules.includes?("code") && has_code_ahead())
      code()
    else
      #                switch (getNextTokenKind()) {
      #                case TokenManager::BACKTICK:
      #                    tree.addSingleValue(new Text(), consumeToken(TokenManager::BACKTICK))
      #                    break
      #                case TokenManager::LBRACK:
      #                    tree.addSingleValue(new Text(), consumeToken(TokenManager::LBRACK))
      #                    break
      #                case TokenManager::UNDERSCORE:
      #                    tree.addSingleValue(new Text(), consumeToken(TokenManager::UNDERSCORE))
      #                    break
      #                }
    end
    #        } while (strongWithinEmMultilineHasElementsAhead())
  end

  def strong_within_em()
    strong = Strong.new()
    @tree.open_scope()
    consume_token(TokenManager::ASTERISK)
    #        do {
    if (has_text_ahead())
      text()
    elsif (modules.includes?("images") && has_image_ahead())
      image()
    elsif (modules.includes?("links") && has_link_ahead())
      link()
    elsif (modules.includes?("code") && has_code_ahead())
      code()
    else
      #                switch (getNextTokenKind()) {
      #                case TokenManager::BACKTICK:
      #                    tree.addSingleValue(new Text(), consumeToken(TokenManager::BACKTICK))
      #                    break
      #                case TokenManager::LBRACK:
      #                    tree.addSingleValue(new Text(), consumeToken(TokenManager::LBRACK))
      #                    break
      #                case TokenManager::UNDERSCORE:
      #                    tree.addSingleValue(new Text(), consumeToken(TokenManager::UNDERSCORE))
      #                    break
      #                }
    end
    #        } while (strongWithinEmHasElementsAhead())
    consume_token(TokenManager::ASTERISK)
    @tree.close_scope(strong)
  end

  def em_multiline()
    em = Em.new()
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
    #        do {
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
      #                switch (getNextTokenKind()) {
      #                case TokenManager::ASTERISK:
      #                    tree.addSingleValue(new Text(), consumeToken(TokenManager::ASTERISK))
      #                    break
      #                case TokenManager::BACKTICK:
      #                    tree.addSingleValue(new Text(), consumeToken(TokenManager::BACKTICK))
      #                    break
      #                case TokenManager::LBRACK:
      #                    tree.addSingleValue(new Text(), consumeToken(TokenManager::LBRACK))
      #                    break
      #                }
    end
    #        } while (emMultilineContentHasElementsAhead())
  end

  def em_within_strong_multiline()
    em = Em.new()
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
    #        do {
    if (has_text_ahead())
      text()
    elsif (modules.includes?("images") && has_image_ahead())
      image()
    elsif (modules.includes?("links") && has_link_ahead())
      link()
    elsif (modules.includes("code") && has_code_ahead())
      code()
    else
      #                switch (getNextTokenKind()) {
      #                case TokenManager::ASTERISK:
      #                    tree.addSingleValue(new Text(), consumeToken(TokenManager::ASTERISK))
      #                    break
      #                case TokenManager::BACKTICK:
      #                    tree.addSingleValue(new Text(), consumeToken(TokenManager::BACKTICK))
      #                    break
      #                case TokenManager::LBRACK:
      #                    tree.addSingleValue(new Text(), consumeToken(TokenManager::LBRACK))
      #                    break
      #                }
    end
    #        } while (emWithinStrongMultilineContentHasElementsAhead())
  end

  def em_within_strong()
    em = Em.new()
    @tree.open_scope()
    consume_token(TokenManager::UNDERSCORE)
    #        do {
    if (has_text_ahead())
      text()
    elsif (modules.includes?("images") && has_image_ahead())
      image()
    elsif (modules.includes?("links") && has_link_ahead())
      link()
    elsif (modules.includes?("code") && has_code_ahead())
      code()
    else
      #                switch (getNextTokenKind()) {
      #                case TokenManager::ASTERISK:
      #                    tree.addSingleValue(new Text(), consumeToken(TokenManager::ASTERISK))
      #                    break
      #                case TokenManager::BACKTICK:
      #                    tree.addSingleValue(new Text(), consumeToken(TokenManager::BACKTICK))
      #                    break
      #                case TokenManager::LBRACK:
      #                    tree.addSingleValue(new Text(), consumeToken(TokenManager::LBRACK))
      #                    break

    end
    #        } while (emWithinStrongHasElementsAhead())
    consume_token(TokenManager::UNDERSCORE)
    @tree.close_scope(em)
  end

  def code_multiline()
    code = Code.new()
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
    #        try {
    look_ahead = 1
    last_position = scan_position = token
    return !scan_more_block_elements()
    #        } catch (LookaheadSuccess ls) {
    #            return true
    #        }
  end

  def block_ahead(block_begin_bolumn)
    quoteLevel = 0

    if (get_next_token_kind() == TokenManager::TokenManager::EOL)
      #            Token t
      i = 2
      quoteLevel = 0
      #            do {
      #                quoteLevel = 0
      #                do {
      #                    t = getToken(i++)
      #                    if (t.kind == TokenManager::GT) {
      #                        if (t.beginColumn == 1 && currentBlockLevel > 0 && currentQuoteLevel == 0) {
      #                            return false
      #                        }
      #                        quoteLevel++
      #                    }
      #                } while (t.kind == TokenManager::GT || t.kind == TokenManager::SPACE || t.kind == TokenManager::TAB)
      #                if (quoteLevel > currentQuoteLevel) {
      #                    return true
      #                }
      #                if (quoteLevel < currentQuoteLevel) {
      #                    return false
      #                }
      #            } while (t.kind == TokenManager::TokenManager::EOL)
      return t.kind != TokenManager::EOF && (@current_block_level == 0 || t.begin_column >= block_begin_bolumn + 2)
    end
    return false
  end

  def multiline_ahead(token)
    if (get_next_token_kind() == token && get_token(2).kind != token && get_token(2).kind != TokenManager::EOL)

      #            for (int i = 2 i++) {
      #                Token t = getToken(i)
      #                if (t.kind == token) {
      #                    return true
      #                } else if (t.kind == TokenManager::TokenManager::EOL) {
      #                    i = skip(i + 1, TokenManager::SPACE, TokenManager::TAB)
      #                    int quoteLevel = newQuoteLevel(i)
      #                    if (quoteLevel == currentQuoteLevel) {
      #                        i = skip(i, TokenManager::SPACE, TokenManager::TAB, TokenManager::GT)
      #                        if (getToken(i).kind == token || getToken(i).kind == TokenManager::TokenManager::EOL || getToken(i).kind == TokenManager::DASH
      #                                || (getToken(i).kind == TokenManager::DIGITS && getToken(i + 1).kind == TokenManager::DOT)
      #                                || (getToken(i).kind == TokenManager::BACKTICK && getToken(i + 1).kind == TokenManager::BACKTICK
      #                                        && getToken(i + 2).kind == TokenManager::BACKTICK)
      #                                || headingAhead(i)) {
      #                            return false
      #                        }
      #                    } else {
      #                        return false
      #                    }
      #                } else if (t.kind == EOF) {
      #                    return false
      #                }
      #            }
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
      #            for (int i = (offset + 1) i++) {
      #                if (getToken(i).kind != TokenManager::EQ) {
      #                    return true
      #                }
      #                if (++heading > 6) {
      #                    return false
      #                }
      #            }
    end
    return false
  end

  def list_item_ahead(listBeginColumn, ordered)
    if (get_next_token_kind() == TokenManager::EOL)
      #            for (int i = 2, TokenManager::TokenManager::EOL = 1 i++) {
      #                Token t = getToken(i)
      #
      #                if (t.kind == TokenManager::TokenManager::EOL && ++TokenManager::TokenManager::EOL > 2) {
      #                    return false
      #                } else if (t.kind != TokenManager::SPACE && t.kind != TokenManager::TAB && t.kind != TokenManager::GT && t.kind != TokenManager::TokenManager::EOL) {
      #                    if (ordered) {
      #                        return (t.kind == TokenManager::DIGITS && getToken(i + 1).kind == TokenManager::DOT && t.beginColumn >= listBeginColumn)
      #                    }
      #                    return t.kind == TokenManager::DASH && t.beginColumn >= listBeginColumn
      #                }
      #            }
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
        return get_token(i).kind != TokenManager::EOL && !(@modules.includes?("lists") && t.kind == TokenManager::DASH)
        #                        && !(@modules.includes?("lists") && t.kind == TokenManager::DIGITS && getToken(i + 1).kind == TokenManager::DOT)
        #                        && !(getToken(i).kind == TokenManager::BACKTICK && getToken(i + 1).kind == TokenManager::BACKTICK
        #                                && getToken(i + 2).kind == TokenManager::BACKTICK)
        #                        && !(modules.contains("headings") && headingAhead(i))
      end
    end
    return false
  end

  def next_after_space(tokens)
    i = skip(1, TokenManager::SPACE, TokenManager::TAB)
    return tokens.includes?(get_token(i).kind)
  end

  def new_quote_level(offset)
    quoteLevel = 0
    #        for (int i = offset i++) {
    #            Token t = getToken(i)
    #            if (t.kind == TokenManager::GT) {
    #                quoteLevel++
    #            } else if (t.kind != TokenManager::SPACE && t.kind != TokenManager::TAB) {
    #                return quoteLevel
    #            }
    #
    #        }
  end

  def skip(offset, tokens)
    #      List<Integer> tokenList = Arrays.asList(tokens)
    #        for (int i = offset i++) {
    #            Token t = getToken(i)
    #            if (!tokenList.contains(t.kind)) {
    #                return i
    #            }
    #        }
  end

  def has_ordered_list_ahead()
    @lookAhead = 2
    @lastPosition = @scanPosition = @token
    #        try {
    #            return !scanToken(TokenManager::DIGITS) && !scanToken(TokenManager::DOT)
    #        } catch (LookaheadSuccess ls) {
    return true
    #        }
  end

  def has_fenced_code_block_ahead()
    @lookAhead = 3
    @lastPosition = @scanPosition = @token
    #        try {
    #            return !scanFencedCodeBlock()
    #        } catch (LookaheadSuccess ls) {
    return true
    #        }
  end

  def heading_has_inline_elements_ahead()
    @look_ahead = 1
    @last_position = @scan_position = @token
    #        try {
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
    #        } catch (LookaheadSuccess ls) {
    return true
    #        }
  end

  def has_text_ahead()
    @lookAhead = 1
    @lastPosition = @scanPosition = @token
    #        try {
    return !scan_text_tokens()
    #        } catch (LookaheadSuccess ls) {
    return true
    #        }
  end

  def has_image_ahead()
    @lookAhead = 2147483647
    @lastPosition = @scanPosition = @token
    #        try {
    return !scan_image()
    #        } catch (LookaheadSuccess ls) {
    return true
    #        }
  end

  def block_quote_has_empty_line_ahead()
    @lookAhead = 2147483647
    @lastPosition = @scanPosition = @token
    #        try {
    return !scan_block_quote_empty_line()
    #        } catch (LookaheadSuccess ls) {
    return true
    #        }
  end

  def has_strong_ahead()
    @lookAhead = 2147483647
    @lastPosition = @scanPosition = @token
    #        try {
    return !scan_strong()
    #        } catch (LookaheadSuccess ls) {
    return true
    #        }
  end

  def has_em_ahead()
    @lookAhead = 2147483647
    @lastPosition = @scanPosition = @token
    #        try {
    return !scan_em()
    #        } catch (LookaheadSuccess ls) {
    return true
    #        }
  end

  def has_code_ahead()
    @lookAhead = 2147483647
    @lastPosition = @scanPosition = @token
    #        try {
    return !scan_code()
    #        } catch (LookaheadSuccess ls) {
    return true
    #        }
  end

  def block_quote_has_any_block_elementse_ahead()
    @lookAhead = 1
    @lastPosition = @scanPosition = @token
    #        try {
    return !scan_more_block_elements()
    #        } catch (LookaheadSuccess ls) {
    return true
    #        }
  end

  def has_block_quote_empty_lines_ahead()
    @lookAhead = 2147483647
    @lastPosition = @scanPosition = @token
    #        try {
    return !scan_block_quote_empty_lines()
    #        } catch (LookaheadSuccess ls) {
    return true
    #        }
  end

  def list_item_has_inline_elements()
    @lookAhead = 1
    @lastPosition = @scanPosition = @token
    #        try {
    return !scan_more_block_elements()
    #        } catch (LookaheadSuccess ls) {
    return true
    #        }
  end

  def has_inline_text_ahead()
    @lookAhead = 1
    @lastPosition = @scanPosition = @token
    #        try {
    return !scan_text_tokens()
    #        } catch (LookaheadSuccess ls) {
    return true
    #        }
  end

  def has_inline_element_ahead()
    @lookAhead = 1
    @lastPosition = @scanPosition = @token
    #        try {
    return !scan_inline_element()
    #        } catch (LookaheadSuccess ls) {
    return true
    #        }
  end

  def image_has_any_elements()
    @lookAhead = 1
    @lastPosition = @scanPosition = @token
    #        try {
    return !scan_image_element()
    #        } catch (LookaheadSuccess ls) {
    return true
    #        }
  end

  def has_resource_text_ahead()
    @lookAhead = 1
    @lastPosition = @scanPosition = @token
    #        try {
    return !scan_resource_elements()
    #        } catch (LookaheadSuccess ls) {
    return true
    #        }
  end

  def link_has_any_elements()
    @lookAhead = 1
    @lastPosition = @scanPosition = @token
    #        try {
    return !scan_link_element()
    #        } catch (LookaheadSuccess ls) {
    return true
    #        }
  end

  def has_resource_url_ahead()
    @lookAhead = 2147483647
    @lastPosition = @scanPosition = @token
    #        try {
    return !scan_resource_url()
    #        } catch (LookaheadSuccess ls) {
    return true
    #        }
  end

  def resource_has_element_ahead()
    @lookAhead = 2
    @lastPosition = @scanPosition = @token
    #        try {
    return !scan_resource_element()
    #        } catch (LookaheadSuccess ls) {
    return true
    #        }
  end

  def resource_text_has_elements_ahead()
    @lookAhead = 1
    @lastPosition = @scanPosition = @token
    #        try {
    return !scan_resource_text_element()
    #        } catch (LookaheadSuccess ls) {
    return true
    #        }
  end

  def has_em_within_strong_multiline()
    @lookAhead = 2147483647
    @lastPosition = @scanPosition = @token
    #        try {
    return !scan_em_within_strong_multiline()
    #        } catch (LookaheadSuccess ls) {
    return true
    #        }
  end

  def strong_multiline_has_elements_ahead()
    @lookAhead = 1
    @lastPosition = @scanPosition = @token
    #        try {
    return !scan_strong_multiline_elements()
    #        } catch (LookaheadSuccess ls) {
    return true
    #        }
  end

  def strong_within_em_multiline_has_elements_ahead()
    @lookAhead = 1
    @lastPosition = @scanPosition = @token
    #        try {
    return !scan_strong_within_em_multiline_elements()
    #        } catch (LookaheadSuccess ls) {
    return true
    #        }
  end

  def has_image()
    @lookAhead = 2147483647
    @lastPosition = @scanPosition = @token
    #        try {
    return !scan_image()
    #        } catch (LookaheadSuccess ls) {
    return true
    #        }
  end

  def has_link_ahead()
    @lookAhead = 2147483647
    @lastPosition = @scanPosition = @token
    #        try {
    return !scan_link()
    #        } catch (LookaheadSuccess ls) {
    return true
    #        }
  end

  def strong_em_within_strong_ahead()
    @lookAhead = 2147483647
    @lastPosition = @scanPosition = @token
    #        try {
    return !scan_em_within_strong()
    #        } catch (LookaheadSuccess ls) {
    return true
    #        }
  end

  def strong_has_elements()
    @lookAhead = 1
    @lastPosition = @scanPosition = @token
    #        try {
    return !scan_strong_elements()
    #        } catch (LookaheadSuccess ls) {
    return true
    #        }
  end

  def strong_within_em_has_elements_ahead()
    @lookAhead = 1
    @lastPosition = @scanPosition = @token
    #        try {
    return !scan_strong_within_em_elements()
    #        } catch (LookaheadSuccess ls) {
    return true
    #        }
  end

  def has_strong_within_em_multiline_ahead()
    @lookAhead = 2147483647
    @lastPosition = @scanPosition = @token
    #        try {
    return !scan_strong_within_em_multiline()
    #        } catch (LookaheadSuccess ls) {
    return true
    #        }
  end

  def em_multiline_content_has_elements_ahead()
    @lookAhead = 1
    @lastPosition = @scanPosition = @token
    #        try {
    return !scan_em_multiline_content_elements()
    #        } catch (LookaheadSuccess ls) {
    return true
    #        }
  end

  def em_within_strong_multiline_content_has_elements_ahead()
    @lookAhead = 1
    @lastPosition = @scanPosition = @token
    #        try {
    return !scan_em_within_strong_multilineContent()
    #        } catch (LookaheadSuccess ls) {
    return true
    #        }
  end

  def em_has_strong_within_em()
    @lookAhead = 2147483647
    @lastPosition = @scanPosition = @token
    #        try {
    return !scan_strong_within_em()
    #        } catch (LookaheadSuccess ls) {
    return true
    #        }
  end

  def em_has_elements()
    @lookAhead = 1
    @lastPosition = @scanPosition = @token
    #        try {
    return !scan_em_elements()
    #        } catch (LookaheadSuccess ls) {
    return true
    #        }
  end

  def em_within_strong_has_elements_ahead()
    @lookAhead = 1
    @lastPosition = @scanPosition = @token
    #        try {
    #            return !scanEmWithinStrongElements()
    #        } catch (LookaheadSuccess ls) {
    #            return true
    #        }
  end

  def code_text_has_any_token_ahead()
    @lookAhead = 1
    @lastPosition = @scanPosition = @token
    #        try {
    return !scan_code_text_tokens()
    #        } catch (LookaheadSuccess ls) {
    return true
    #        }
  end

  def text_has_tokens_ahead()
    @lookAhead = 1
    @lastPosition = @scanPosition = @token
    #        try {
    return !scan_text()
    #        } catch (LookaheadSuccess ls) {
    return true
    #        }
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
    #       Token xsp
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
    #        Token xsp
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
    #        Token xsp
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
    #        Token xsp
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
    #        Token xsp
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
    #        Token xsp
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
    #        Token xsp
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
    #        Token xsp
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
    #        Token xsp
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
    #        Token xsp
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
    #        Token xsp
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
    #        Token xsp
    #        while (true) {
    #            xsp = scanPosition
    #            if (scanStrongWithinEmMultilineElements()) {
    #                scanPosition = xsp
    #                break
    #            }
    #        }
    return false
  end

  def scan_strong_within_em_multiline()
    if (scan_token(TokenManager::ASTERISK) || scan_for_more_strong_within_em_multiline_elements())
      return true
    end
    #        Token xsp
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
    #        Token xsp
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
    #        Token xsp
    while (true)
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
    #        Token xsp
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
    #        Token xsp
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
    #        Token xsp
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
    #        Token xsp = scanPosition
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
    #        Token xsp
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
    #        Token xsp
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
      #            scanPosition = xsp
      #            if (scanToken(TokenManager::GT)) {
      #                scanPosition = xsp
      #                if (scanToken(TokenManager::DASH)) {
      #                    scanPosition = xsp
      #                    if (scanToken(TokenManager::DIGITS) || scanToken(TokenManager::DOT)) {
      #                        scanPosition = xsp
      #                        if (scanFencedCodeBlock()) {
      #                            scanPosition = xsp
      #                            return scanParagraph()
      #                        }
      #                    }
      #                }
      #            }
    end
    #        return false
  end

  def scan_token(kind)
    #        if (scanPosition == lastPosition) {
    #            lookAhead--
    #            if (scanPosition.next == null) {
    #                lastPosition = scanPosition = scanPosition.next = tm.getNextToken()
    #            } else {
    #                lastPosition = scanPosition = scanPosition.next
    #            }
    #        } else {
    #            scanPosition = scanPosition.next
    #        }
    #        if (scanPosition.kind != kind) {
    #            return true
    #        }
    #        if (lookAhead == 0 && scanPosition == lastPosition) {
    #            throw lookAheadSuccess
    #        }
    return false
  end

  def get_next_token_kind()
    #        if (nextTokenKind != -1) {
    #            return nextTokenKind
    #        } else if ((nextToken = token.next) == null) {
    #            token.next = tm.getNextToken()
    #            return (nextTokenKind = token.next.kind)
    #        }
    #        return (nextTokenKind = nextToken.kind)
  end

  def consume_token(kind)
    old = @token
    #        if (token.next != null) {
    #            token = token.next
    #        } else {
    #            token = token.next = tm.getNextToken()
    #        }
    #        nextTokenKind = -1
    #        if (token.kind == kind) {
    #            return token
    #        }
    #        token = old
    return @token
  end

  def get_token(index)
    #        Token t = lookingAhead ? scanPosition : token
    #        for (int i = 0 i < index i++) {
    #            if (t.next != null) {
    #                t = t.next
    #            } else {
    #                t = t.next = tm.getNextToken()
    #            }
    #        }
    return t
  end

  def setModules(modules)
    this.modules = Arrays.asList(modules)
  end

end
