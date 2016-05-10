require_relative 'lookahead_success'

class Parser
  attr_reader :modules
  #    private CharStream cs;
  #    private Token token, nextToken, scanPosition, lastPosition;
  #    private TokenManager tm;
  #    private TreeState tree;
  #    private int currentBlockLevel;
  #    private int currentQuoteLevel;
  #    private int lookAhead;
  #    private int nextTokenKind;
  #    private boolean lookingAhead;
  #    private boolean semanticLookAhead;
  #    private LookaheadSuccess lookAheadSuccess;
  #
  def initialize
    @lookAheadSuccess = LookaheadSuccess.new
    @modules = ["paragraphs", "headings", "lists", "links", "images", "formatting", "blockquotes", "code"]
  end

  def parse(text)
    parse_reader(text);
  end

  def parse_file(file)
    #      if(!file.getName().toLowerCase().endsWith(".kd")) {
    #        throw new IllegalArgumentException("Can only parse files with extension .kd");
    #      }
    #        return parseReader(new FileReader(file));
  end

  def parse_reader(reader)
    @cs =  CharStream.new(reader)
    @tm =  TokenManager.new(cs)
    @token =  Token.new
    @tree = TreeState.new
    @nextTokenKind = -1
    document = Document.new
    tree.open_scope
    #        while (getNextTokenKind() == EOL) {
    #            consumeToken(EOL);
    #        }
    #
    white_space
    #        if (hasAnyBlockElementsAhead()) {
    #            blockElement();
    #            while (blockAhead(0)) {
    #                while (getNextTokenKind() == EOL) {
    #                    consumeToken(EOL);
    #                    whiteSpace();
    #                }
    #                blockElement();
    #            }
    #            while (getNextTokenKind() == EOL) {
    #                consumeToken(EOL);
    #            }
    #            whiteSpace();
    #        }
    consume_token(EOF)
    @tree.close_scope(document)
    return document
  end

  #
  def block_element
    @current_block_level += 1
    #        if (modules.contains("headings") && headingAhead(1)) {
    #            heading();
    #        } else if (modules.contains("blockquotes") && getNextTokenKind() == GT) {
    #            blockQuote();
    #        } else if (modules.contains("lists") && getNextTokenKind() == DASH) {
    #            unorderedList();
    #        } else if (modules.contains("lists") && hasOrderedListAhead()) {
    #            orderedList();
    #        } else if (modules.contains("code") && hasFencedCodeBlockAhead()) {
    #            fencedCodeBlock();
    #        } else {
    #            paragraph();
    #        }
    @current_block_level -= 1
  end

  def heading
    heading =  Heading.new()
    tree.open_scope()
    headingLevel = 0
    #
    #        while (getNextTokenKind() == EQ) {
    #            consumeToken(EQ);
    #            headingLevel++;
    #        }
    white_space()
    #        while (headingHasInlineElementsAhead()) {
    #            if (hasTextAhead()) {
    #                text();
    #            } else if (modules.contains("images") && hasImageAhead()) {
    #                image();
    #            } else if (modules.contains("links") && hasLinkAhead()) {
    #                link();
    #            } else if (modules.contains("formatting") && hasStrongAhead()) {
    #                strong();
    #            } else if (modules.contains("formatting") && hasEmAhead()) {
    #                em();
    #            } else if (modules.contains("code") && hasCodeAhead()) {
    #                code();
    #            } else {
    #                looseChar();
    #            }
    #        }
    heading.value = headingLevel
    tree.close_scope(heading);
  end

  def block_quote
    blockquote = BlockQuote.new()
    @tree.open_scope()
    @current_quote_Level += 1
    consume_token(GT)
    #        while (blockQuoteHasEmptyLineAhead()) {
    #            blockQuoteEmptyLine();
    #        }
    #        whiteSpace();
    #        if (blockQuoteHasAnyBlockElementseAhead()) {
    #            blockElement();
    #            while (blockAhead(0)) {
    #                while (getNextTokenKind() == EOL) {
    #                    consumeToken(EOL);
    #                    whiteSpace();
    #                    blockQuotePrefix();
    #                }
    #                blockElement();
    #            }
    #        }
    #        while (hasBlockQuoteEmptyLinesAhead()) {
    #            blockQuoteEmptyLine();
    #        }
    current_quote_level -= 1
    tree.close_scope(blockquote)
  end

  def block_quote_prefix()
    i = 0
    #        do {
    #            consumeToken(GT);
    #            whiteSpace();
    #        } while (++i < currentQuoteLevel);
  end

  def block_quote_empty_line()
    consume_token(EOL)
    white_space()
    #        do {
    #            consumeToken(GT);
    #            whiteSpace();
    #        } while (getNextTokenKind() == GT);
  end

  def unordered_list
    list =  ListBlock.new(false)
    @tree.open_scope()
    listBeginColumn = unordered_list_item()
    #        while (listItemAhead(listBeginColumn, false)) {
    #            while (getNextTokenKind() == EOL) {
    #                consumeToken(EOL);
    #            }
    #            whiteSpace();
    #            if (currentQuoteLevel > 0) {
    #                blockQuotePrefix();
    #            }
    #            unorderedListItem();
    #        }
    tree.close_scope(list);
  end

  def unordered_list_item()
    listItem = ListItem.new()
    @tree.open_scope()

    t = consumeToken(DASH)
    white_space()
    #        if (listItemHasInlineElements()) {
    #            blockElement();
    #            while (blockAhead(t.beginColumn)) {
    #                while (getNextTokenKind() == EOL) {
    #                    consumeToken(EOL);
    #                    whiteSpace();
    #                    if (currentQuoteLevel > 0) {
    #                        blockQuotePrefix();
    #                    }
    #                }
    #                blockElement();
    #            }
    #        }
    @tree.close_scope(list_item)
    return t.beginColumn;
  end

  def ordered_list
    list = ListBlock.new(true)
    @tree.open_scope()
    listBeginColumn = ordered_list_item()
    #        while (listItemAhead(listBeginColumn, true)) {
    #            while (getNextTokenKind() == EOL) {
    #                consumeToken(EOL);
    #            }
    #            whiteSpace();
    #            if (currentQuoteLevel > 0) {
    #                blockQuotePrefix();
    #            }
    #            orderedListItem();
    #        }
    @tree.closeScope(list)
  end

  def ordered_list_item
    list_item = ListItem.new()
    @tree.open_scope()
    t = consume_token(DIGITS)
    consume_token(DOT)
    white_space()
    if (list_item_has_inline_elements())
      block_element()
      #            while (blockAhead(t.beginColumn)) {
      #                while (getNextTokenKind() == EOL) {
      #                    consumeToken(EOL);
      #                    whiteSpace();
      #                    if (currentQuoteLevel > 0) {
      #                        blockQuotePrefix();
      #                    }
      #                }
      #                blockElement();
      #            }
    end
    list_item.number = t.image
    @tree.close_scope(list_item)
    return t.begin_column
  end

  def fenced_code_block
    codeBlock = CodeBlock.new()
    @tree.open_scope()
    #        StringBuilder s = new StringBuilder();
    beginColumn = consume_token(BACKTICK).begin_column
    #        do {
    #            consumeToken(BACKTICK);
    #        } while (getNextTokenKind() == BACKTICK);
    #        whiteSpace();
    #        if (getNextTokenKind() == CHAR_SEQUENCE) {
    #            codeBlock.setLanguage(codeLanguage());
    #        }
    #        if (getNextTokenKind() != EOF && !fencesAhead()) {
    #            consumeToken(EOL);
    #            levelWhiteSpace(beginColumn);
    #        }
    #
    kind = get_next_token_kind()
    #        while (kind != EOF && ((kind != EOL && kind != BACKTICK) || !fencesAhead())) {
    #            switch (kind) {
    #          case CHAR_SEQUENCE:
    #            s.append(consumeToken(CHAR_SEQUENCE).image);
    #            break;
    #            case ASTERISK:
    #                s.append(consumeToken(ASTERISK).image);
    #                break;
    #            case BACKSLASH:
    #                s.append(consumeToken(BACKSLASH).image);
    #                break;
    #            case COLON:
    #                s.append(consumeToken(COLON).image);
    #                break;
    #            case DASH:
    #                s.append(consumeToken(DASH).image);
    #                break;
    #            case DIGITS:
    #                s.append(consumeToken(DIGITS).image);
    #                break;
    #            case DOT:
    #                s.append(consumeToken(DOT).image);
    #                break;
    #            case EQ:
    #                s.append(consumeToken(EQ).image);
    #                break;
    #            case ESCAPED_CHAR:
    #                s.append(consumeToken(ESCAPED_CHAR).image);
    #                break;
    #            case IMAGE_LABEL:
    #                s.append(consumeToken(IMAGE_LABEL).image);
    #                break;
    #            case LT:
    #                s.append(consumeToken(LT).image);
    #                break;
    #            case GT:
    #                s.append(consumeToken(GT).image);
    #                break;
    #            case LBRACK:
    #                s.append(consumeToken(LBRACK).image);
    #                break;
    #            case RBRACK:
    #                s.append(consumeToken(RBRACK).image);
    #                break;
    #            case LPAREN:
    #                s.append(consumeToken(LPAREN).image);
    #                break;
    #            case RPAREN:
    #                s.append(consumeToken(RPAREN).image);
    #                break;
    #            case UNDERSCORE:
    #                s.append(consumeToken(UNDERSCORE).image);
    #                break;
    #            case BACKTICK:
    #                s.append(consumeToken(BACKTICK).image);
    #                break;
    #            default:
    #                if (!nextAfterSpace(EOL, EOF)) {
    #                    switch (kind) {
    #                    case SPACE:
    #                        s.append(consumeToken(SPACE).image);
    #                        break;
    #                    case TAB:
    #                        consumeToken(TAB);
    #                        s.append("    ");
    #                        break;
    #                    }
    #                } else if (!fencesAhead()) {
    #                    consumeToken(EOL);
    #                    s.append("\n");
    #                    levelWhiteSpace(beginColumn);
    #                }
    #            }
    #            kind = getNextTokenKind();
    #        }
    if (fences_ahead())
      consume_token(EOL)
      white_space()
      #            while (getNextTokenKind() == BACKTICK) {
      #                consumeToken(BACKTICK);
      #            }
    end
    #        codeBlock.setValue(s.toString());
    @tree.close_scope(code_block)
  end

  def paragraph()
    #        BlockElement paragraph = modules.contains("paragraphs") ? new Paragraph() : new BlockElement();
    @tree.open_scope()
    inline()
    #        while (textAhead()) {
    #            lineBreak();
    #            whiteSpace();
    #            if (modules.contains("blockquotes")) {
    #                while (getNextTokenKind() == GT) {
    #                    consumeToken(GT);
    #                    whiteSpace();
    #                }
    #            }
    #            inline();
    #        }
    @tree.close_scope(paragraph)
  end

  def text
    text = Text.new()
    @tree.open_scope()
    #        StringBuffer s = new StringBuffer();
    #        while (textHasTokensAhead()) {
    #            switch (getNextTokenKind()) {
    #          case CHAR_SEQUENCE:
    #            s.append(consumeToken(CHAR_SEQUENCE).image);
    #            break;
    #            case BACKSLASH:
    #                s.append(consumeToken(BACKSLASH).image);
    #                break;
    #            case COLON:
    #                s.append(consumeToken(COLON).image);
    #                break;
    #            case DASH:
    #                s.append(consumeToken(DASH).image);
    #                break;
    #            case DIGITS:
    #                s.append(consumeToken(DIGITS).image);
    #                break;
    #            case DOT:
    #                s.append(consumeToken(DOT).image);
    #                break;
    #            case EQ:
    #                s.append(consumeToken(EQ).image);
    #                break;
    #            case ESCAPED_CHAR:
    #                s.append(consumeToken(ESCAPED_CHAR).image.substring(1));
    #                break;
    #            case GT:
    #                s.append(consumeToken(GT).image);
    #                break;
    #            case IMAGE_LABEL:
    #                s.append(consumeToken(IMAGE_LABEL).image);
    #                break;
    #            case LPAREN:
    #                s.append(consumeToken(LPAREN).image);
    #                break;
    #            case LT:
    #                s.append(consumeToken(LT).image);
    #                break;
    #            case RBRACK:
    #                s.append(consumeToken(RBRACK).image);
    #                break;
    #            case RPAREN:
    #                s.append(consumeToken(RPAREN).image);
    #                break;
    #            default:
    #                if (!nextAfterSpace(EOL, EOF)) {
    #                    switch (getNextTokenKind()) {
    #                    case SPACE:
    #                        s.append(consumeToken(SPACE).image);
    #                        break;
    #                    case TAB:
    #                        consumeToken(TAB);
    #                        s.append("    ");
    #                        break;
    #                    }
    #                }
    #            }
    #        }
    #        text.setValue(s.toString());
    @tree.close_scope(text)
  end

  def image
    image = Image.new()
    @tree.open_scope()
    #        String ref = "";
    consume_token(LBRACK)
    white_space()
    consume_token(IMAGE_LABEL)
    white_space()
    #        while (imageHasAnyElements()) {
    #            if (hasTextAhead()) {
    #                resourceText();
    #            } else {
    #                looseChar();
    #            }
    #        }
    white_space()
    consume_token(RBRACK);
    if (has_resource_url_ahead())
      #            ref = resourceUrl();
    end
    image.value = ref
    @tree.close_scope(image)
  end

  def link()
    link = Link.new()
    @tree.open_scope()
    #        String ref = "";
    consume_token(LBRACK)
    white_space()
    #        while (linkHasAnyElements()) {
    #            if (modules.contains("images") && hasImageAhead()) {
    #                image();
    #            } else if (modules.contains("formatting") && hasStrongAhead()) {
    #                strong();
    #            } else if (modules.contains("formatting") && hasEmAhead()) {
    #                em();
    #            } else if (modules.contains("code") && hasCodeAhead()) {
    #                code();
    #            } else if (hasResourceTextAhead()) {
    #                resourceText();
    #            } else {
    #                looseChar();
    #            }
    #        }
    white_space()
    consume_token(RBRACK)
    if (hasResourceUrlAhead())
      ref = resource_url()
    end
    link.value = ref
    @tree.close_scope(link)
  end

  def strong()
    strong = Strong.new()
    @tree.open_scope()
    consume_token(ASTERISK)
    #        while (strongHasElements()) {
    #            if (hasTextAhead()) {
    #                text();
    #            } else if (modules.contains("images") && hasImage()) {
    #                image();
    #            } else if (modules.contains("links") && hasLinkAhead()) {
    #                link();
    #            } else if (modules.contains("code") && multilineAhead(BACKTICK)) {
    #                codeMultiline();
    #            } else if (strongEmWithinStrongAhead()) {
    #                emWithinStrong();
    #            } else {
    #                switch (getNextTokenKind()) {
    #                case BACKTICK:
    #                    tree.addSingleValue(new Text(), consumeToken(BACKTICK));
    #                    break;
    #                case LBRACK:
    #                    tree.addSingleValue(new Text(), consumeToken(LBRACK));
    #                    break;
    #                case UNDERSCORE:
    #                    tree.addSingleValue(new Text(), consumeToken(UNDERSCORE));
    #                    break;
    #                }
    #            }
    #        }
    consume_token(ASTERISK)
    @tree.close_scope(strong)
  end

  def em
    em = Em.new()
    @tree.open_scope()
    consume_Token(UNDERSCORE);
    #        while (emHasElements()) {
    #            if (hasTextAhead()) {
    #                text();
    #            } else if (modules.contains("images") && hasImage()) {
    #                image();
    #            } else if (modules.contains("links") && hasLinkAhead()) {
    #                link();
    #            } else if (modules.contains("code") && hasCodeAhead()) {
    #                code();
    #            } else if (emHasStrongWithinEm()) {
    #                strongWithinEm();
    #            } else {
    #                switch (getNextTokenKind()) {
    #                case ASTERISK:
    #                    tree.addSingleValue(new Text(), consumeToken(ASTERISK));
    #                    break;
    #                case BACKTICK:
    #                    tree.addSingleValue(new Text(), consumeToken(BACKTICK));
    #                    break;
    #                case LBRACK:
    #                    tree.addSingleValue(new Text(), consumeToken(LBRACK));
    #                    break;
    #                }
    #            }
    #        }
    consume_token(UNDERSCORE)
    tree.close_scope(em)
  end

  def code()
    code = Code.new
    tree.open_scope()
    consume_token(BACKTICK)
    code_text()
    consumetToken(BACKTICK)
    tree.close_scope(code)
  end

  def code_text()
    text = Text.new()
    tree.open_scope()
    #        StringBuffer s = new StringBuffer();
    #        do {
    #            switch (getNextTokenKind()) {
    #          case CHAR_SEQUENCE:
    #            s.append(consumeToken(CHAR_SEQUENCE).image);
    #            break;
    #            case ASTERISK:
    #                s.append(consumeToken(ASTERISK).image);
    #                break;
    #            case BACKSLASH:
    #                s.append(consumeToken(BACKSLASH).image);
    #                break;
    #            case COLON:
    #                s.append(consumeToken(COLON).image);
    #                break;
    #            case DASH:
    #                s.append(consumeToken(DASH).image);
    #                break;
    #            case DIGITS:
    #                s.append(consumeToken(DIGITS).image);
    #                break;
    #            case DOT:
    #                s.append(consumeToken(DOT).image);
    #                break;
    #            case EQ:
    #                s.append(consumeToken(EQ).image);
    #                break;
    #            case ESCAPED_CHAR:
    #                s.append(consumeToken(ESCAPED_CHAR).image);
    #                break;
    #            case IMAGE_LABEL:
    #                s.append(consumeToken(IMAGE_LABEL).image);
    #                break;
    #            case LT:
    #                s.append(consumeToken(LT).image);
    #                break;
    #            case LBRACK:
    #                s.append(consumeToken(LBRACK).image);
    #                break;
    #            case RBRACK:
    #                s.append(consumeToken(RBRACK).image);
    #                break;
    #            case LPAREN:
    #                s.append(consumeToken(LPAREN).image);
    #                break;
    #            case GT:
    #                s.append(consumeToken(GT).image);
    #                break;
    #            case RPAREN:
    #                s.append(consumeToken(RPAREN).image);
    #                break;
    #            case UNDERSCORE:
    #                s.append(consumeToken(UNDERSCORE).image);
    #                break;
    #            default:
    #                if (!nextAfterSpace(EOL, EOF)) {
    #                    switch (getNextTokenKind()) {
    #                    case SPACE:
    #                        s.append(consumeToken(SPACE).image);
    #                        break;
    #                    case TAB:
    #                        consumeToken(TAB);
    #                        s.append("    ");
    #                        break;
    #                    }
    #                }
    #            }
    #        } while (codeTextHasAnyTokenAhead());
    #        text.setValue(s.toString());
    @tree.close_scope(text)
  end

  def loose_char()
    text = Text.new()
    @tree.open_scope()
    #        switch (getNextTokenKind()) {
    #        case ASTERISK:
    #            text.setValue(consumeToken(ASTERISK).image);
    #            break;
    #        case BACKTICK:
    #            text.setValue(consumeToken(BACKTICK).image);
    #            break;
    #        case LBRACK:
    #            text.setValue(consumeToken(LBRACK).image);
    #            break;
    #        case UNDERSCORE:
    #            text.setValue(consumeToken(UNDERSCORE).image);
    #            break;
    #        }
    @tree.close_scope(text)
  end

  def line_break
    linebreak = LineBreak.new()
    tree.open_scope()
    #        while (getNextTokenKind() == SPACE || getNextTokenKind() == TAB) {
    #            consumeToken(getNextTokenKind());
    #        }
    consume_token(EOL)
    tree.close_scope(linebreak)
  end

  def level_white_space(threshold)
    currentPos = 1
    #        while (getNextTokenKind() == GT) {
    #            consumeToken(getNextTokenKind());
    #        }
    #        while ((getNextTokenKind() == SPACE || getNextTokenKind() == TAB) && currentPos < (threshold - 1)) {
    #            currentPos = consumeToken(getNextTokenKind()).beginColumn;
    #        }
  end

  def code_language
    #        StringBuilder s = new StringBuilder();
    #        do {
    #            switch (getNextTokenKind()) {
    #          case CHAR_SEQUENCE:
    #            s.append(consumeToken(CHAR_SEQUENCE).image);
    #            break;
    #            case ASTERISK:
    #                s.append(consumeToken(ASTERISK).image);
    #                break;
    #            case BACKSLASH:
    #                s.append(consumeToken(BACKSLASH).image);
    #                break;
    #            case BACKTICK:
    #                s.append(consumeToken(BACKTICK).image);
    #                break;
    #            case COLON:
    #                s.append(consumeToken(COLON).image);
    #                break;
    #            case DASH:
    #                s.append(consumeToken(DASH).image);
    #                break;
    #            case DIGITS:
    #                s.append(consumeToken(DIGITS).image);
    #                break;
    #            case DOT:
    #                s.append(consumeToken(DOT).image);
    #                break;
    #            case EQ:
    #                s.append(consumeToken(EQ).image);
    #                break;
    #            case ESCAPED_CHAR:
    #                s.append(consumeToken(ESCAPED_CHAR).image);
    #                break;
    #            case IMAGE_LABEL:
    #                s.append(consumeToken(IMAGE_LABEL).image);
    #                break;
    #            case LT:
    #                s.append(consumeToken(LT).image);
    #                break;
    #            case GT:
    #                s.append(consumeToken(GT).image);
    #                break;
    #            case LBRACK:
    #                s.append(consumeToken(LBRACK).image);
    #                break;
    #            case RBRACK:
    #                s.append(consumeToken(RBRACK).image);
    #                break;
    #            case LPAREN:
    #                s.append(consumeToken(LPAREN).image);
    #                break;
    #            case RPAREN:
    #                s.append(consumeToken(RPAREN).image);
    #                break;
    #            case UNDERSCORE:
    #                s.append(consumeToken(UNDERSCORE).image);
    #                break;
    #            case SPACE:
    #                s.append(consumeToken(SPACE).image);
    #                break;
    #            case TAB:
    #                s.append("    ");
    #                break;
    #            default:
    #                break;
    #            }
    #        } while (getNextTokenKind() != EOL && getNextTokenKind() != EOF);
    #        return s.toString();
  end

  def inline
    #        do {
    #            if (hasInlineTextAhead()) {
    #                text();
    #            } else if (modules.contains("images") && hasImageAhead()) {
    #                image();
    #            } else if (modules.contains("links") && hasLinkAhead()) {
    #                link();
    #            } else if (modules.contains("formatting") && multilineAhead(ASTERISK)) {
    #                strongMultiline();
    #            } else if (modules.contains("formatting") && multilineAhead(UNDERSCORE)) {
    #                emMultiline();
    #            } else if (modules.contains("code") && multilineAhead(BACKTICK)) {
    #                codeMultiline();
    #            } else {
    #                looseChar();
    #            }
    #        } while (hasInlineElementAhead());
  end

  def resource_text
    text = Text.new()
    tree.open_scope()
    #        StringBuilder s = new StringBuilder();
    #        do {
    #            switch (getNextTokenKind()) {
    #          case CHAR_SEQUENCE:
    #            s.append(consumeToken(CHAR_SEQUENCE).image);
    #            break;
    #            case BACKSLASH:
    #                s.append(consumeToken(BACKSLASH).image);
    #                break;
    #            case COLON:
    #                s.append(consumeToken(COLON).image);
    #                break;
    #            case DASH:
    #                s.append(consumeToken(DASH).image);
    #                break;
    #            case DIGITS:
    #                s.append(consumeToken(DIGITS).image);
    #                break;
    #            case DOT:
    #                s.append(consumeToken(DOT).image);
    #                break;
    #            case EQ:
    #                s.append(consumeToken(EQ).image);
    #                break;
    #            case ESCAPED_CHAR:
    #                s.append(consumeToken(ESCAPED_CHAR).image.substring(1));
    #                break;
    #            case IMAGE_LABEL:
    #                s.append(consumeToken(IMAGE_LABEL).image);
    #                break;
    #            case GT:
    #                s.append(consumeToken(GT).image);
    #                break;
    #            case LPAREN:
    #                s.append(consumeToken(LPAREN).image);
    #                break;
    #            case LT:
    #                s.append(consumeToken(LT).image);
    #                break;
    #            case RPAREN:
    #                s.append(consumeToken(RPAREN).image);
    #                break;
    #            default:
    #                if (!nextAfterSpace(RBRACK)) {
    #                    switch (getNextTokenKind()) {
    #                    case SPACE:
    #                        s.append(consumeToken(SPACE).image);
    #                        break;
    #                    case TAB:
    #                        consumeToken(TAB);
    #                        s.append("    ");
    #                        break;
    #                    }
    #                }
    #            }
    #        } while (resourceHasElementAhead());
    #        text.setValue(s.toString());
    tree.close_scope(text)
  end

  def resource_url
    consume_token(LPAREN);
    white_space()
    ref = resourceUrlText();
    white_space()
    consume_token(RPAREN)
    return ref
  end

  def resource_url_text
    #        StringBuilder s = new StringBuilder();
    #        while (resourceTextHasElementsAhead()) {
    #            switch (getNextTokenKind()) {
    #          case CHAR_SEQUENCE:
    #            s.append(consumeToken(CHAR_SEQUENCE).image);
    #            break;
    #            case ASTERISK:
    #                s.append(consumeToken(ASTERISK).image);
    #                break;
    #            case BACKSLASH:
    #                s.append(consumeToken(BACKSLASH).image);
    #                break;
    #            case BACKTICK:
    #                s.append(consumeToken(BACKTICK).image);
    #                break;
    #            case COLON:
    #                s.append(consumeToken(COLON).image);
    #                break;
    #            case DASH:
    #                s.append(consumeToken(DASH).image);
    #                break;
    #            case DIGITS:
    #                s.append(consumeToken(DIGITS).image);
    #                break;
    #            case DOT:
    #                s.append(consumeToken(DOT).image);
    #                break;
    #            case EQ:
    #                s.append(consumeToken(EQ).image);
    #                break;
    #            case ESCAPED_CHAR:
    #                s.append(consumeToken(ESCAPED_CHAR).image.substring(1));
    #                break;
    #            case IMAGE_LABEL:
    #                s.append(consumeToken(IMAGE_LABEL).image);
    #                break;
    #            case GT:
    #                s.append(consumeToken(GT).image);
    #                break;
    #            case LBRACK:
    #                s.append(consumeToken(LBRACK).image);
    #                break;
    #            case LPAREN:
    #                s.append(consumeToken(LPAREN).image);
    #                break;
    #            case LT:
    #                s.append(consumeToken(LT).image);
    #                break;
    #            case RBRACK:
    #                s.append(consumeToken(RBRACK).image);
    #                break;
    #            case UNDERSCORE:
    #                s.append(consumeToken(UNDERSCORE).image);
    #                break;
    #            default:
    #                if (!nextAfterSpace(RPAREN)) {
    #                    switch (getNextTokenKind()) {
    #                    case SPACE:
    #                        s.append(consumeToken(SPACE).image);
    #                        break;
    #                    case TAB:
    #                        consumeToken(TAB);
    #                        s.append("    ");
    #                        break;
    #                    }
    #                }
    #            }
    #        }
    #        return s.toString();
  end

  def strong_multiline
    Strong strong = Strong.new()
    @tree.open_scope()
    consume_token(ASTERISK)
    strong_multiline_content()
    #        while (textAhead()) {
    #            lineBreak();
    #            whiteSpace();
    #            strongMultilineContent();
    #        }
    consume_token(ASTERISK)
    @tree.close_scope(strong)
  end

  def strong_multiline_content
    #        do {
    #            if (hasTextAhead()) {
    #                text();
    #            } else if (modules.contains("images") && hasImageAhead()) {
    #                image();
    #            } else if (modules.contains("links") && hasLinkAhead()) {
    #                link();
    #            } else if (modules.contains("code") && hasCodeAhead()) {
    #                code();
    #            } else if (hasEmWithinStrongMultiline()) {
    #                emWithinStrongMultiline();
    #            } else {
    #                switch (getNextTokenKind()) {
    #                case BACKTICK:
    #                    tree.addSingleValue(new Text(), consumeToken(BACKTICK));
    #                    break;
    #                case LBRACK:
    #                    tree.addSingleValue(new Text(), consumeToken(LBRACK));
    #                    break;
    #                case UNDERSCORE:
    #                    tree.addSingleValue(new Text(), consumeToken(UNDERSCORE));
    #                    break;
    #                }
    #            }
    #        } while (strongMultilineHasElementsAhead());
  end

  def strong_within_em_multiline
    Strong strong = Strong.new
    tree.open_scope()
    consume_token(ASTERISK)
    strong_within_em_eultilineContent()
    #        while (textAhead()) {
    #            lineBreak();
    #            strongWithinEmMultilineContent();
    #        }
    consume_token(ASTERISK)
    tree.close_scope(strong)
  end

  def strong_within_em_multiline_content
    #        do {
    #            if (hasTextAhead()) {
    #                text();
    #            } else if (modules.contains("images") && hasImageAhead()) {
    #                image();
    #            } else if (modules.contains("links") && hasLinkAhead()) {
    #                link();
    #            } else if (modules.contains("code") && hasCodeAhead()) {
    #                code();
    #            } else {
    #                switch (getNextTokenKind()) {
    #                case BACKTICK:
    #                    tree.addSingleValue(new Text(), consumeToken(BACKTICK));
    #                    break;
    #                case LBRACK:
    #                    tree.addSingleValue(new Text(), consumeToken(LBRACK));
    #                    break;
    #                case UNDERSCORE:
    #                    tree.addSingleValue(new Text(), consumeToken(UNDERSCORE));
    #                    break;
    #                }
    #            }
    #        } while (strongWithinEmMultilineHasElementsAhead());
  end

  def strong_within_em
    strong = Strong.new()
    @tree.open_scope()
    consume_token(ASTERISK)
    #        do {
    #            if (hasTextAhead()) {
    #                text();
    #            } else if (modules.contains("images") && hasImageAhead()) {
    #                image();
    #            } else if (modules.contains("links") && hasLinkAhead()) {
    #                link();
    #            } else if (modules.contains("code") && hasCodeAhead()) {
    #                code();
    #            } else {
    #                switch (getNextTokenKind()) {
    #                case BACKTICK:
    #                    tree.addSingleValue(new Text(), consumeToken(BACKTICK));
    #                    break;
    #                case LBRACK:
    #                    tree.addSingleValue(new Text(), consumeToken(LBRACK));
    #                    break;
    #                case UNDERSCORE:
    #                    tree.addSingleValue(new Text(), consumeToken(UNDERSCORE));
    #                    break;
    #                }
    #            }
    #        } while (strongWithinEmHasElementsAhead());
    consume_token(ASTERISK)
    @tree.close_scope(strong)
  end

  def em_multiline
    em = Em.new()
    tree.open_scope()
    consume_token(UNDERSCORE)
    em_multiline_content()
    #        while (textAhead()) {
    #            lineBreak();
    #            whiteSpace();
    #            emMultilineContent();
    #        }
    consume_token(UNDERSCORE);
    tree.close_scope(em)
  end

  def em_multiline_content
    #        do {
    #            if (hasTextAhead()) {
    #                text();
    #            } else if (modules.contains("images") && hasImageAhead()) {
    #                image();
    #            } else if (modules.contains("links") && hasLinkAhead()) {
    #                link();
    #            } else if (modules.contains("code") && multilineAhead(BACKTICK)) {
    #                codeMultiline();
    #            } else if (hasStrongWithinEmMultilineAhead()) {
    #                strongWithinEmMultiline();
    #            } else {
    #                switch (getNextTokenKind()) {
    #                case ASTERISK:
    #                    tree.addSingleValue(new Text(), consumeToken(ASTERISK));
    #                    break;
    #                case BACKTICK:
    #                    tree.addSingleValue(new Text(), consumeToken(BACKTICK));
    #                    break;
    #                case LBRACK:
    #                    tree.addSingleValue(new Text(), consumeToken(LBRACK));
    #                    break;
    #                }
    #            }
    #        } while (emMultilineContentHasElementsAhead());
  end

  def em_within_strong_multiline
    em = Em.new()
    tree.open_scope()
    consume_token(UNDERSCORE)
    em_within_strong_multiline_content()
    #        while (textAhead()) {
    #            lineBreak();
    #            emWithinStrongMultilineContent();
    #        }
    consume_token(UNDERSCORE)
    tree.close_scope(em)
  end

  def em_within_strong_multiline_content
    #        do {
    #            if (hasTextAhead()) {
    #                text();
    #            } else if (modules.contains("images") && hasImageAhead()) {
    #                image();
    #            } else if (modules.contains("links") && hasLinkAhead()) {
    #                link();
    #            } else if (modules.contains("code") && hasCodeAhead()) {
    #                code();
    #            } else {
    #                switch (getNextTokenKind()) {
    #                case ASTERISK:
    #                    tree.addSingleValue(new Text(), consumeToken(ASTERISK));
    #                    break;
    #                case BACKTICK:
    #                    tree.addSingleValue(new Text(), consumeToken(BACKTICK));
    #                    break;
    #                case LBRACK:
    #                    tree.addSingleValue(new Text(), consumeToken(LBRACK));
    #                    break;
    #                }
    #            }
    #        } while (emWithinStrongMultilineContentHasElementsAhead());
  end

  def em_within_strong
    em = Em.new()
    @tree.open_scope()
    consume_token(UNDERSCORE)
    #        do {
    #            if (hasTextAhead()) {
    #                text();
    #            } else if (modules.contains("images") && hasImageAhead()) {
    #                image();
    #            } else if (modules.contains("links") && hasLinkAhead()) {
    #                link();
    #            } else if (modules.contains("code") && hasCodeAhead()) {
    #                code();
    #            } else {
    #                switch (getNextTokenKind()) {
    #                case ASTERISK:
    #                    tree.addSingleValue(new Text(), consumeToken(ASTERISK));
    #                    break;
    #                case BACKTICK:
    #                    tree.addSingleValue(new Text(), consumeToken(BACKTICK));
    #                    break;
    #                case LBRACK:
    #                    tree.addSingleValue(new Text(), consumeToken(LBRACK));
    #                    break;
    #                }
    #            }
    #        } while (emWithinStrongHasElementsAhead());
    consume_token(UNDERSCORE)
    @tree.close_scope(em)
  end

  def code_multiline
    code = Code.new();
    @tree.openScope();
    consume_token(BACKTICK)
    code_text()
    #        while (textAhead()) {
    #            lineBreak();
    #            whiteSpace();
    #            while (getNextTokenKind() == GT) {
    #                consumeToken(GT);
    #                whiteSpace();
    #            }
    #            codeText();
    #        }
    consume_token(BACKTICK)
    @tree.close_scope(code)
  end

  def white_space
    #        while (getNextTokenKind() == SPACE || getNextTokenKind() == TAB) {
    #            consumeToken(getNextTokenKind());
    #        }
  end

  def has_any_block_elements_ahead
    #        try {
    #            lookAhead = 1;
    #            lastPosition = scanPosition = token;
    #            return !scanMoreBlockElements();
    #        } catch (LookaheadSuccess ls) {
    #            return true;
    #        }
  end

  def block_ahead(blockBeginColumn)
    quoteLevel = 0;

    if (get_next_token_kind() == EOL)
      #            Token t;
      #            int i = 2;
      #            quoteLevel = 0;
      #            do {
      #                quoteLevel = 0;
      #                do {
      #                    t = getToken(i++);
      #                    if (t.kind == GT) {
      #                        if (t.beginColumn == 1 && currentBlockLevel > 0 && currentQuoteLevel == 0) {
      #                            return false;
      #                        }
      #                        quoteLevel++;
      #                    }
      #                } while (t.kind == GT || t.kind == SPACE || t.kind == TAB);
      #                if (quoteLevel > currentQuoteLevel) {
      #                    return true;
      #                }
      #                if (quoteLevel < currentQuoteLevel) {
      #                    return false;
      #                }
      #            } while (t.kind == EOL);
      #            return t.kind != EOF && (currentBlockLevel == 0 || t.beginColumn >= blockBeginColumn + 2);
    end
    return false;
  end

  def multiline_ahead(token)
    #        if (getNextTokenKind() == token && getToken(2).kind != token && getToken(2).kind != EOL) {
    #
    #            for (int i = 2;; i++) {
    #                Token t = getToken(i);
    #                if (t.kind == token) {
    #                    return true;
    #                } else if (t.kind == EOL) {
    #                    i = skip(i + 1, SPACE, TAB);
    #                    int quoteLevel = newQuoteLevel(i);
    #                    if (quoteLevel == currentQuoteLevel) {
    #                        i = skip(i, SPACE, TAB, GT);
    #                        if (getToken(i).kind == token || getToken(i).kind == EOL || getToken(i).kind == DASH
    #                                || (getToken(i).kind == DIGITS && getToken(i + 1).kind == DOT)
    #                                || (getToken(i).kind == BACKTICK && getToken(i + 1).kind == BACKTICK
    #                                        && getToken(i + 2).kind == BACKTICK)
    #                                || headingAhead(i)) {
    #                            return false;
    #                        }
    #                    } else {
    #                        return false;
    #                    }
    #                } else if (t.kind == EOF) {
    #                    return false;
    #                }
    #            }
    #        }
    return false
  end

  def fences_ahead
    #        int i = skip(2, SPACE, TAB, GT);
    #        if (getToken(i).kind == BACKTICK && getToken(i + 1).kind == BACKTICK && getToken(i + 2).kind == BACKTICK) {
    #            i = skip(i + 3, SPACE, TAB);
    #            return getToken(i).kind == EOL || getToken(i).kind == EOF;
    #        }
    return false
  end

  def heading_ahead(offset)
    #        if (getToken(offset).kind == EQ) {
    #            int heading = 1;
    #            for (int i = (offset + 1);; i++) {
    #                if (getToken(i).kind != EQ) {
    #                    return true;
    #                }
    #                if (++heading > 6) {
    #                    return false;
    #                }
    #            }
    #        }
    #        return false;
  end

  def list_item_ahead(listBeginColumn, ordered)
    #        if (getNextTokenKind() == EOL) {
    #            for (int i = 2, eol = 1;; i++) {
    #                Token t = getToken(i);
    #
    #                if (t.kind == EOL && ++eol > 2) {
    #                    return false;
    #                } else if (t.kind != SPACE && t.kind != TAB && t.kind != GT && t.kind != EOL) {
    #                    if (ordered) {
    #                        return (t.kind == DIGITS && getToken(i + 1).kind == DOT && t.beginColumn >= listBeginColumn);
    #                    }
    #                    return t.kind == DASH && t.beginColumn >= listBeginColumn;
    #                }
    #            }
    #        }
    return false
  end

  def text_ahead
    #        if (getNextTokenKind() == EOL && getToken(2).kind != EOL) {
    #            int i = skip(2, SPACE, TAB);
    #            int quoteLevel = newQuoteLevel(i);
    #            if (quoteLevel == currentQuoteLevel || !modules.contains("blockquotes")) {
    #                i = skip(i, SPACE, TAB, GT);
    #
    #                Token t = getToken(i);
    #                return getToken(i).kind != EOL && !(modules.contains("lists") && t.kind == DASH)
    #                        && !(modules.contains("lists") && t.kind == DIGITS && getToken(i + 1).kind == DOT)
    #                        && !(getToken(i).kind == BACKTICK && getToken(i + 1).kind == BACKTICK
    #                                && getToken(i + 2).kind == BACKTICK)
    #                        && !(modules.contains("headings") && headingAhead(i));
    #            }
    #        }
    return false
  end

  def next_after_space(tokens)
    i = skip(1, SPACE, TAB)
    #        return Arrays.asList(tokens).contains(getToken(i).kind);
  end

  def new_quote_level(offset)
    quoteLevel = 0
    #        for (int i = offset;; i++) {
    #            Token t = getToken(i);
    #            if (t.kind == GT) {
    #                quoteLevel++;
    #            } else if (t.kind != SPACE && t.kind != TAB) {
    #                return quoteLevel;
    #            }
    #
    #        }
  end

  def skip(offset, tokens)
    #      List<Integer> tokenList = Arrays.asList(tokens);
    #        for (int i = offset;; i++) {
    #            Token t = getToken(i);
    #            if (!tokenList.contains(t.kind)) {
    #                return i;
    #            }
    #        }
  end

  def has_ordered_list_ahead()
    @lookAhead = 2;
    @lastPosition = @scanPosition = @token;
    #        try {
    #            return !scanToken(DIGITS) && !scanToken(DOT);
    #        } catch (LookaheadSuccess ls) {
    #            return true;
    #        }
  end

  def has_fenced_code_block_ahead()
    @lookAhead = 3;
    @lastPosition = @scanPosition = @token;
    #        try {
    #            return !scanFencedCodeBlock();
    #        } catch (LookaheadSuccess ls) {
    #            return true;
    #        }
  end

  def heading_has_inline_elements_ahead()
    @lookAhead = 1;
    @lastPosition = @scanPosition = @token;
    #        try {
    #            Token xsp = scanPosition;
    #            if (scanTextTokens()) {
    #                scanPosition = xsp;
    #                if (scanImage()) {
    #                    scanPosition = xsp;
    #                    if (scanLink()) {
    #                        scanPosition = xsp;
    #                        if (scanStrong()) {
    #                            scanPosition = xsp;
    #                            if (scanEm()) {
    #                                scanPosition = xsp;
    #                                if (scanCode()) {
    #                                    scanPosition = xsp;
    #                                    if (scanLooseChar()) {
    #                                        return false;
    #                                    }
    #                                }
    #                            }
    #                        }
    #                    }
    #                }
    #            }
    return true;
    #        } catch (LookaheadSuccess ls) {
    return true;
    #        }
  end

  def has_text_ahead
    @lookAhead = 1;
    @lastPosition = @scanPosition = @token;
    #        try {
    #            return !scanTextTokens();
    #        } catch (LookaheadSuccess ls) {
    #            return true;
    #        }
  end

  def has_image_ahead
    @lookAhead = 2147483647;
    @lastPosition = @scanPosition = @token;
    #        try {
    #            return !scanImage();
    #        } catch (LookaheadSuccess ls) {
    #            return true;
    #        }
  end

  def block_quote_has_empty_line_ahead
    @lookAhead = 2147483647;
    @lastPosition = @scanPosition = @token;
    #        try {
    #            return !scanBlockQuoteEmptyLine();
    #        } catch (LookaheadSuccess ls) {
    #            return true;
    #        }
  end

  def has_strong_ahead
    @lookAhead = 2147483647;
    @lastPosition = @scanPosition = @token;
    #        try {
    #            return !scanStrong();
    #        } catch (LookaheadSuccess ls) {
    #            return true;
    #        }
  end

  def has_em_ahead
    @lookAhead = 2147483647;
    @lastPosition = @scanPosition = @token;
    #        try {
    #            return !scanEm();
    #        } catch (LookaheadSuccess ls) {
    #            return true;
    #        }
  end

  def has_code_ahead
    @lookAhead = 2147483647;
    @lastPosition = @scanPosition = @token;
    #        try {
    #            return !scanCode();
    #        } catch (LookaheadSuccess ls) {
    #            return true;
    #        }
  end

  def block_quote_has_any_block_elementse_ahead
    @lookAhead = 1;
    @lastPosition = @scanPosition = @token;
    #        try {
    #            return !scanMoreBlockElements();
    #        } catch (LookaheadSuccess ls) {
    #            return true;
    #        }
  end

  def has_block_quote_empty_lines_ahead
    @lookAhead = 2147483647;
    @lastPosition = @scanPosition = @token;
    #        try {
    #            return !scanBlockQuoteEmptyLines();
    #        } catch (LookaheadSuccess ls) {
    #            return true;
    #        }
  end

  def list_item_has_inline_elements
    @lookAhead = 1;
    @lastPosition = @scanPosition = @token;
    #        try {
    #            return !scanMoreBlockElements();
    #        } catch (LookaheadSuccess ls) {
    #            return true;
    #        }
  end

  def has_inline_text_ahead
    @lookAhead = 1;
    @lastPosition = @scanPosition = @token;
    #        try {
    #            return !scanTextTokens();
    #        } catch (LookaheadSuccess ls) {
    #            return true;
    #        }
  end

  def has_inline_element_ahead
    @lookAhead = 1;
    @lastPosition = @scanPosition = @token;
    #        try {
    #            return !scanInlineElement();
    #        } catch (LookaheadSuccess ls) {
    #            return true;
    #        }
  end

  def image_has_any_elements
    @lookAhead = 1;
    @lastPosition = @scanPosition = @token;
    #        try {
    #            return !scanImageElement();
    #        } catch (LookaheadSuccess ls) {
    #            return true;
    #        }
  end

  def has_resource_text_ahead
    @lookAhead = 1;
    @lastPosition = @scanPosition = @token;
    #        try {
    #            return !scanResourceElements();
    #        } catch (LookaheadSuccess ls) {
    #            return true;
    #        }
  end

  def link_has_any_elements
    @lookAhead = 1;
    @lastPosition = @scanPosition = @token;
    #        try {
    #            return !scanLinkElement();
    #        } catch (LookaheadSuccess ls) {
    #            return true;
    #        }
  end

  def has_resource_url_ahead
    @lookAhead = 2147483647;
    @lastPosition = @scanPosition = @token;
    #        try {
    #            return !scanResourceUrl();
    #        } catch (LookaheadSuccess ls) {
    #            return true;
    #        }
  end

  def resource_has_element_ahead
    @lookAhead = 2;
    @lastPosition = @scanPosition = @token;
    #        try {
    #            return !scanResourceElement();
    #        } catch (LookaheadSuccess ls) {
    #            return true;
    #        }
  end

  def resource_text_has_elements_ahead
    @lookAhead = 1;
    @lastPosition = @scanPosition = @token;
    #        try {
    #            return !scanResourceTextElement();
    #        } catch (LookaheadSuccess ls) {
    #            return true;
    #        }
  end

  def has_em_within_strong_multiline
    @lookAhead = 2147483647;
    @lastPosition = @scanPosition = @token;
    #        try {
    #            return !scanEmWithinStrongMultiline();
    #        } catch (LookaheadSuccess ls) {
    #            return true;
    #        }
  end

  def strong_multiline_has_elements_ahead
    @lookAhead = 1;
    @lastPosition = @scanPosition = @token;
    #        try {
    #            return !scanStrongMultilineElements();
    #        } catch (LookaheadSuccess ls) {
    #            return true;
    #        }
  end

  def strong_within_em_multiline_has_elements_ahead
    @lookAhead = 1;
    @lastPosition = @scanPosition = @token;
    #        try {
    #            return !scanStrongWithinEmMultilineElements();
    #        } catch (LookaheadSuccess ls) {
    #            return true;
    #        }
  end

  def has_image
    @lookAhead = 2147483647;
    @lastPosition = @scanPosition = @token;
    #        try {
    #            return !scanImage();
    #        } catch (LookaheadSuccess ls) {
    #            return true;
    #        }
  end

  def has_link_ahead
    @lookAhead = 2147483647;
    @lastPosition = @scanPosition = @token;
    #        try {
    #            return !scanLink();
    #        } catch (LookaheadSuccess ls) {
    #            return true;
    #        }
  end

  def strong_em_within_strong_ahead
    @lookAhead = 2147483647;
    @lastPosition = @scanPosition = @token;
    #        try {
    #            return !scanEmWithinStrong();
    #        } catch (LookaheadSuccess ls) {
    #            return true;
    #        }
  end

  def strong_has_elements
    @lookAhead = 1;
    @lastPosition = @scanPosition = @token;
    #        try {
    #            return !scanStrongElements();
    #        } catch (LookaheadSuccess ls) {
    #            return true;
    #        }
  end

  def strong_within_em_has_elements_ahead
    @lookAhead = 1;
    @lastPosition = @scanPosition = @token;
    #        try {
    #            return !scanStrongWithinEmElements();
    #        } catch (LookaheadSuccess ls) {
    #            return true;
    #        }
  end

  def has_strong_within_em_multiline_ahead
    @lookAhead = 2147483647;
    @lastPosition = @scanPosition = @token;
    #        try {
    #            return !scanStrongWithinEmMultiline();
    #        } catch (LookaheadSuccess ls) {
    #            return true;
    #        }
  end

  def em_multiline_content_has_elements_ahead
    @lookAhead = 1;
    @lastPosition = @scanPosition = @token;
    #        try {
    #            return !scanEmMultilineContentElements();
    #        } catch (LookaheadSuccess ls) {
    #            return true;
    #        }
  end

  def em_within_strong_multiline_content_has_elements_ahead
    @lookAhead = 1;
    @lastPosition = @scanPosition = @token;
    #        try {
    #            return !scanEmWithinStrongMultilineContent();
    #        } catch (LookaheadSuccess ls) {
    #            return true;
    #        }
  end

  def em_has_strong_within_em
    @lookAhead = 2147483647;
    @lastPosition = @scanPosition = @token;
    #        try {
    #            return !scanStrongWithinEm();
    #        } catch (LookaheadSuccess ls) {
    #            return true;
    #        }
  end

  def em_has_elements
    @lookAhead = 1;
    @lastPosition = @scanPosition = @token;
    #        try {
    #            return !scanEmElements();
    #        } catch (LookaheadSuccess ls) {
    #            return true;
    #        }
  end

  def em_within_strong_has_elements_ahead
    @lookAhead = 1;
    @lastPosition = @scanPosition = @token;
    #        try {
    #            return !scanEmWithinStrongElements();
    #        } catch (LookaheadSuccess ls) {
    #            return true;
    #        }
  end

  def code_text_has_any_token_ahead
    @lookAhead = 1;
    @lastPosition = @scanPosition = @token;
    #        try {
    #            return !scanCodeTextTokens();
    #        } catch (LookaheadSuccess ls) {
    #            return true;
    #        }
  end

  def text_has_tokens_ahead
    @lookAhead = 1;
    @lastPosition = @scanPosition = @token;
    #        try {
    #            return !scanText();
    #        } catch (LookaheadSuccess ls) {
    #            return true;
    #        }
  end

  def scan_loose_char
    xsp = @scanPosition
    #        if (scanToken(ASTERISK)) {
    #            scanPosition = xsp;
    #            if (scanToken(BACKTICK)) {
    #                scanPosition = xsp;
    #                if (scanToken(LBRACK)) {
    #                    scanPosition = xsp;
    #                    return scanToken(UNDERSCORE);
    #                }
    #            }
    #        }
    #        return false;
  end

  def scan_text
    xsp = scanPosition
    #        if (scanToken(BACKSLASH)) {
    #            scanPosition = xsp;
    #            if (scanToken(CHAR_SEQUENCE)) {
    #                scanPosition = xsp;
    #                if (scanToken(COLON)) {
    #                    scanPosition = xsp;
    #                    if (scanToken(DASH)) {
    #                        scanPosition = xsp;
    #                        if (scanToken(DIGITS)) {
    #                            scanPosition = xsp;
    #                            if (scanToken(DOT)) {
    #                                scanPosition = xsp;
    #                                if (scanToken(EQ)) {
    #                                    scanPosition = xsp;
    #                                    if (scanToken(ESCAPED_CHAR)) {
    #                                        scanPosition = xsp;
    #                                        if (scanToken(GT)) {
    #                                            scanPosition = xsp;
    #                                            if (scanToken(IMAGE_LABEL)) {
    #                                                scanPosition = xsp;
    #                                                if (scanToken(LPAREN)) {
    #                                                    scanPosition = xsp;
    #                                                    if (scanToken(LT)) {
    #                                                        scanPosition = xsp;
    #                                                        if (scanToken(RBRACK)) {
    #                                                            scanPosition = xsp;
    #                                                            if (scanToken(RPAREN)) {
    #                                                                scanPosition = xsp;
    #                                                                lookingAhead = true;
    #                                                                semanticLookAhead = !nextAfterSpace(EOL, EOF);
    #                                                                lookingAhead = false;
    #                                                                return (!semanticLookAhead || scanWhitspaceToken());
    #                                                            }
    #                                                        }
    #                                                    }
    #                                                }
    #                                            }
    #                                        }
    #                                    }
    #                                }
    #                            }
    #                        }
    #                    }
    #                }
    #            }
    #        }
    return false
  end

  def scan_text_tokens
    if (scan_text())
      return true
    end
    #        Token xsp;
    #        while (true) {
    #            xsp = scanPosition;
    #            if (scanText()) {
    #                scanPosition = xsp;
    #                break;
    #            }
    #        }
    #        return false;
  end

  def scan_code_text_tokens
    xsp = @scanPosition
    #        if (scanToken(ASTERISK)) {
    #            scanPosition = xsp;
    #            if (scanToken(BACKSLASH)) {
    #                scanPosition = xsp;
    #                if (scanToken(CHAR_SEQUENCE)) {
    #                    scanPosition = xsp;
    #                    if (scanToken(COLON)) {
    #                        scanPosition = xsp;
    #                        if (scanToken(DASH)) {
    #                            scanPosition = xsp;
    #                            if (scanToken(DIGITS)) {
    #                                scanPosition = xsp;
    #                                if (scanToken(DOT)) {
    #                                    scanPosition = xsp;
    #                                    if (scanToken(EQ)) {
    #                                        scanPosition = xsp;
    #                                        if (scanToken(ESCAPED_CHAR)) {
    #                                            scanPosition = xsp;
    #                                            if (scanToken(IMAGE_LABEL)) {
    #                                                scanPosition = xsp;
    #                                                if (scanToken(LT)) {
    #                                                    scanPosition = xsp;
    #                                                    if (scanToken(LBRACK)) {
    #                                                        scanPosition = xsp;
    #                                                        if (scanToken(RBRACK)) {
    #                                                            scanPosition = xsp;
    #                                                            if (scanToken(LPAREN)) {
    #                                                                scanPosition = xsp;
    #                                                                if (scanToken(GT)) {
    #                                                                    scanPosition = xsp;
    #                                                                    if (scanToken(RPAREN)) {
    #                                                                        scanPosition = xsp;
    #                                                                        if (scanToken(UNDERSCORE)) {
    #                                                                            scanPosition = xsp;
    #                                                                            lookingAhead = true;
    #                                                                            semanticLookAhead = !nextAfterSpace(EOL,
    #                                                                                    EOF);
    #                                                                            lookingAhead = false;
    #                                                                            return (!semanticLookAhead
    #                                                                                    || scanWhitspaceToken());
    #                                                                        }
    #                                                                    }
    #                                                                }
    #                                                            }
    #                                                        }
    #                                                    }
    #                                                }
    #                                            }
    #                                        }
    #                                    }
    #                                }
    #                            }
    #                        }
    #                    }
    #                }
    #            }
    #        }
    #        return false;
  end

  def scan_code
    return scan_token(BACKTICK) || scan_code_text_tokens_ahead() || scan_token(BACKTICK)
  end

  def scan_code_multiline
    if (scan_token(BACKTICK) || scan_code_text_tokens_ahead())
      return true
    end
    #        Token xsp;
    #        while (true) {
    #            xsp = scanPosition;
    #            if (hasCodeTextOnNextLineAhead()) {
    #                scanPosition = xsp;
    #                break;
    #            }
    #        }
    #        return scanToken(BACKTICK);
  end

  def scan_code_text_tokens_ahead
    if (scanCodeTextTokens())
      return true
    end
    #        Token xsp;
    #        while (true) {
    #            xsp = scanPosition;
    #            if (scanCodeTextTokens()) {
    #                scanPosition = xsp;
    #                break;
    #            }
    #        }
    #        return false;
  end

  def has_code_text_on_next_line_ahead()
    if (scan_whitespace_token_before_eol())
      return true
    end
    #        Token xsp;
    #        while (true) {
    #            xsp = scanPosition;
    #            if (scanToken(GT)) {
    #                scanPosition = xsp;
    #                break;
    #            }
    #        }
    #        return scanCodeTextTokensAhead();
  end

  def scan_whitspace_tokens()
    #        Token xsp;
    #        while (true) {
    #            xsp = scanPosition;
    #            if (scanWhitspaceToken()) {
    #                scanPosition = xsp;
    #                break;
    #            }
    #        }
    #        return false;
  end

  def scan_whitespace_token_before_eol()
    return scan_whitspace_tokens() || scan_token(EOL)
  end

  def scan_em_within_strong_elements
    #        Token xsp = scanPosition;
    #        if (scanTextTokens()) {
    #            scanPosition = xsp;
    #            if (scanImage()) {
    #                scanPosition = xsp;
    #                if (scanLink()) {
    #                    scanPosition = xsp;
    #                    if (scanCode()) {
    #                        scanPosition = xsp;
    #                        if (scanToken(ASTERISK)) {
    #                            scanPosition = xsp;
    #                            if (scanToken(BACKTICK)) {
    #                                scanPosition = xsp;
    #                                return scanToken(LBRACK);
    #                            }
    #                        }
    #                    }
    #                }
    #            }
    #        }
    #        return false;
  end

  def scan_em_within_strong
    #        if (scanToken(UNDERSCORE) || scanEmWithinStrongElements()) {
    #            return true;
    #        }
    #        Token xsp;
    #        while (true) {
    #            xsp = scanPosition;
    #            if (scanEmWithinStrongElements()) {
    #                scanPosition = xsp;
    #                break;
    #            }
    #        }
    #        return scanToken(UNDERSCORE);
  end

  def scan_em_elements
    #        Token xsp = scanPosition;
    #        if (scanTextTokens()) {
    #            scanPosition = xsp;
    #            if (scanImage()) {
    #                scanPosition = xsp;
    #                if (scanLink()) {
    #                    scanPosition = xsp;
    #                    if (scanCode()) {
    #                        scanPosition = xsp;
    #                        if (scanStrongWithinEm()) {
    #                            scanPosition = xsp;
    #                            if (scanToken(ASTERISK)) {
    #                                scanPosition = xsp;
    #                                if (scanToken(BACKTICK)) {
    #                                    scanPosition = xsp;
    #                                    return scanToken(LBRACK);
    #                                }
    #                            }
    #                        }
    #                    }
    #                }
    #            }
    #        }
    return false
  end

  def scan_em
    if (scanToken(UNDERSCORE) || scanEmElements())
      return true;
    end
    #        Token xsp;
    #        while (true) {
    #            xsp = scanPosition;
    #            if (scanEmElements()) {
    #                scanPosition = xsp;
    #                break;
    #            }
    #        }
    #        return scanToken(UNDERSCORE);
  end

  def scan_em_within_strong_multiline_content
    #        Token xsp = scanPosition;
    #        if (scanTextTokens()) {
    #            scanPosition = xsp;
    #            if (scanImage()) {
    #                scanPosition = xsp;
    #                if (scanLink()) {
    #                    scanPosition = xsp;
    #                    if (scanCode()) {
    #                        scanPosition = xsp;
    #                        if (scanToken(ASTERISK)) {
    #                            scanPosition = xsp;
    #                            if (scanToken(BACKTICK)) {
    #                                scanPosition = xsp;
    #                                return scanToken(LBRACK);
    #                            }
    #                        }
    #                    }
    #                }
    #            }
    #        }
    return false
  end

  def has_no_em_within_strong_multiline_content_ahead
    #        if (scanEmWithinStrongMultilineContent()) {
    #            return true;
    #        }
    #        Token xsp;
    #        while (true) {
    #            xsp = scanPosition;
    #            if (scanEmWithinStrongMultilineContent()) {
    #                scanPosition = xsp;
    #                break;
    #            }
    #        }
    #        return false;
  end

  def scan_em_within_strong_multiline
    if (scan_token(UNDERSCORE) || has_no_em_within_strong_multiline_content_ahead())
      return true
    end
    #        Token xsp;
    #        while (true) {
    #            xsp = scanPosition;
    #            if (scanWhitespaceTokenBeforeEol() || hasNoEmWithinStrongMultilineContentAhead()) {
    #                scanPosition = xsp;
    #                break;
    #            }
    #        }
    #        return scanToken(UNDERSCORE);
  end

  def scan_em_multiline_content_elements
    xsp = @scanPosition;
    #        if (scanTextTokens()) {
    #            scanPosition = xsp;
    #            if (scanImage()) {
    #                scanPosition = xsp;
    #                if (scanLink()) {
    #                    scanPosition = xsp;
    #                    lookingAhead = true;
    #                    semanticLookAhead = multilineAhead(BACKTICK);
    #                    lookingAhead = false;
    #                    if (!semanticLookAhead || scanCodeMultiline()) {
    #                        scanPosition = xsp;
    #                        if (scanStrongWithinEmMultiline()) {
    #                            scanPosition = xsp;
    #                            if (scanToken(ASTERISK)) {
    #                                scanPosition = xsp;
    #                                if (scanToken(BACKTICK)) {
    #                                    scanPosition = xsp;
    #                                    return scanToken(LBRACK);
    #                                }
    #                            }
    #                        }
    #                    }
    #                }
    #            }
    #        }
    #        return false;
  end

  def scan_strong_within_em_elements()
    #        Token xsp = scanPosition;
    #        if (scanTextTokens()) {
    #            scanPosition = xsp;
    #            if (scanImage()) {
    #                scanPosition = xsp;
    #                if (scanLink()) {
    #                    scanPosition = xsp;
    #                    if (scanCode()) {
    #                        scanPosition = xsp;
    #                        if (scanToken(BACKTICK)) {
    #                            scanPosition = xsp;
    #                            if (scanToken(LBRACK)) {
    #                                scanPosition = xsp;
    #                                return scanToken(UNDERSCORE);
    #                            }
    #                        }
    #                    }
    #                }
    #            }
    #        }
    #        return false;
  end

  def scan_strong_within_em()
    if (scan_token(ASTERISK) || scan_strong_within_em_elements())
      return true;
    end
    #        Token xsp;
    #        while (true) {
    #            xsp = scanPosition;
    #            if (scanStrongWithinEmElements()) {
    #                scanPosition = xsp;
    #                break;
    #            }
    #        }
    #        return scanToken(ASTERISK);
  end

  def scan_strong_elements
    #        Token xsp = scanPosition;
    #        if (scanTextTokens()) {
    #            scanPosition = xsp;
    #            if (scanImage()) {
    #                scanPosition = xsp;
    #                if (scanLink()) {
    #                    scanPosition = xsp;
    #                    lookingAhead = true;
    #                    semanticLookAhead = multilineAhead(BACKTICK);
    #                    lookingAhead = false;
    #                    if (!semanticLookAhead || scanCodeMultiline()) {
    #                        scanPosition = xsp;
    #                        if (scanEmWithinStrong()) {
    #                            scanPosition = xsp;
    #                            if (scanToken(BACKTICK)) {
    #                                scanPosition = xsp;
    #                                if (scanToken(LBRACK)) {
    #                                    scanPosition = xsp;
    #                                    return scanToken(UNDERSCORE);
    #                                }
    #                            }
    #                        }
    #                    }
    #                }
    #            }
    #        }
    return false
  end

  def scan_strong
    #        if (scanToken(ASTERISK) || scanStrongElements()) {
    #            return true;
    #        }
    #        Token xsp;
    #        while (true) {
    #            xsp = scanPosition;
    #            if (scanStrongElements()) {
    #                scanPosition = xsp;
    #                break;
    #            }
    #        }
    return scan_token(ASTERISK)
  end

  def scan_strong_within_em_multiline_elements()
    xsp = @scanPosition;
    #        if (scanTextTokens()) {
    #            scanPosition = xsp;
    #            if (scanImage()) {
    #                scanPosition = xsp;
    #                if (scanLink()) {
    #                    scanPosition = xsp;
    #                    if (scanCode()) {
    #                        scanPosition = xsp;
    #                        if (scanToken(BACKTICK)) {
    #                            scanPosition = xsp;
    #                            if (scanToken(LBRACK)) {
    #                                scanPosition = xsp;
    #                                return scanToken(UNDERSCORE);
    #                            }
    #                        }
    #                    }
    #                }
    #            }
    #        }
    return false
  end

  def scan_for_more_strong_within_em_multiline_elements()
    if (scanStrongWithinEmMultilineElements())
      return true
    end
    #        Token xsp;
    #        while (true) {
    #            xsp = scanPosition;
    #            if (scanStrongWithinEmMultilineElements()) {
    #                scanPosition = xsp;
    #                break;
    #            }
    #        }
            return false
  end

  def scan_strong_within_em_multiline
            if (scan_token(ASTERISK) || scan_for_more_strong_within_em_multiline_elements())
                return true;
            end
    #        Token xsp;
    #        while (true) {
    #            xsp = scanPosition;
    #            if (scanWhitespaceTokenBeforeEol() || scanForMoreStrongWithinEmMultilineElements()) {
    #                scanPosition = xsp;
    #                break;
    #            }
    #        }
    #        return scanToken(ASTERISK);
  end

  def scan_strong_multiline_elements
    #        Token xsp = scanPosition;
    #        if (scanTextTokens()) {
    #            scanPosition = xsp;
    #            if (scanImage()) {
    #                scanPosition = xsp;
    #                if (scanLink()) {
    #                    scanPosition = xsp;
    #                    if (scanCode()) {
    #                        scanPosition = xsp;
    #                        if (scanEmWithinStrongMultiline()) {
    #                            scanPosition = xsp;
    #                            if (scanToken(BACKTICK)) {
    #                                scanPosition = xsp;
    #                                if (scanToken(LBRACK)) {
    #                                    scanPosition = xsp;
    #                                    return scanToken(UNDERSCORE);
    #                                }
    #                            }
    #                        }
    #                    }
    #                }
    #            }
    #        }
    #        return false;
  end

  def scan_resource_text_element
    #        Token xsp = scanPosition;
    #        if (scanToken(ASTERISK)) {
    #            scanPosition = xsp;
    #            if (scanToken(BACKSLASH)) {
    #                scanPosition = xsp;
    #                if (scanToken(BACKTICK)) {
    #                    scanPosition = xsp;
    #                    if (scanToken(CHAR_SEQUENCE)) {
    #                        scanPosition = xsp;
    #                        if (scanToken(COLON)) {
    #                            scanPosition = xsp;
    #                            if (scanToken(DASH)) {
    #                                scanPosition = xsp;
    #                                if (scanToken(DIGITS)) {
    #                                    scanPosition = xsp;
    #                                    if (scanToken(DOT)) {
    #                                        scanPosition = xsp;
    #                                        if (scanToken(EQ)) {
    #                                            scanPosition = xsp;
    #                                            if (scanToken(ESCAPED_CHAR)) {
    #                                                scanPosition = xsp;
    #                                                if (scanToken(IMAGE_LABEL)) {
    #                                                    scanPosition = xsp;
    #                                                    if (scanToken(GT)) {
    #                                                        scanPosition = xsp;
    #                                                        if (scanToken(LBRACK)) {
    #                                                            scanPosition = xsp;
    #                                                            if (scanToken(LPAREN)) {
    #                                                                scanPosition = xsp;
    #                                                                if (scanToken(LT)) {
    #                                                                    scanPosition = xsp;
    #                                                                    if (scanToken(RBRACK)) {
    #                                                                        scanPosition = xsp;
    #                                                                        if (scanToken(UNDERSCORE)) {
    #                                                                            scanPosition = xsp;
    #                                                                            lookingAhead = true;
    #                                                                            semanticLookAhead = !nextAfterSpace(RPAREN);
    #                                                                            lookingAhead = false;
    #                                                                            return (!semanticLookAhead
    #                                                                                    || scanWhitspaceToken());
    #                                                                        }
    #                                                                    }
    #                                                                }
    #                                                            }
    #                                                        }
    #                                                    }
    #                                                }
    #                                            }
    #                                        }
    #                                    }
    #                                }
    #                            }
    #                        }
    #                    }
    #                }
    #            }
    #        }
    #        return false;
  end

  def scan_image_element
    #        Token xsp = scanPosition;
    #        if (scanResourceElements()) {
    #            scanPosition = xsp;
    #            if (scanLooseChar()) {
    #                return true;
    #            }
    #        }
    #        return false;
  end

  def scan_resource_text_elements
    #        Token xsp;
    #        while (true) {
    #            xsp = scanPosition;
    #            if (scanResourceTextElement()) {
    #                scanPosition = xsp;
    #                break;
    #            }
    #        }
    #        return false;
  end

  def scan_resource_url
    #        return scanToken(LPAREN) || scanWhitspaceTokens() || scanResourceTextElements() || scanWhitspaceTokens()
    #                || scanToken(RPAREN);
  end

  def scan_link_element
    #        Token xsp = scanPosition;
    #        if (scanImage()) {
    #            scanPosition = xsp;
    #            if (scanStrong()) {
    #                scanPosition = xsp;
    #                if (scanEm()) {
    #                    scanPosition = xsp;
    #                    if (scanCode()) {
    #                        scanPosition = xsp;
    #                        if (scanResourceElements()) {
    #                            scanPosition = xsp;
    #                            return scanLooseChar();
    #                        }
    #                    }
    #                }
    #            }
    #        }
    #        return false;
  end

  def scan_resource_element
    #        Token xsp = scanPosition;
    #        if (scanToken(BACKSLASH)) {
    #            scanPosition = xsp;
    #            if (scanToken(COLON)) {
    #                scanPosition = xsp;
    #                if (scanToken(CHAR_SEQUENCE)) {
    #                    scanPosition = xsp;
    #                    if (scanToken(DASH)) {
    #                        scanPosition = xsp;
    #                        if (scanToken(DIGITS)) {
    #                            scanPosition = xsp;
    #                            if (scanToken(DOT)) {
    #                                scanPosition = xsp;
    #                                if (scanToken(EQ)) {
    #                                    scanPosition = xsp;
    #                                    if (scanToken(ESCAPED_CHAR)) {
    #                                        scanPosition = xsp;
    #                                        if (scanToken(IMAGE_LABEL)) {
    #                                            scanPosition = xsp;
    #                                            if (scanToken(GT)) {
    #                                                scanPosition = xsp;
    #                                                if (scanToken(LPAREN)) {
    #                                                    scanPosition = xsp;
    #                                                    if (scanToken(LT)) {
    #                                                        scanPosition = xsp;
    #                                                        if (scanToken(RPAREN)) {
    #                                                            scanPosition = xsp;
    #                                                            lookingAhead = true;
    #                                                            semanticLookAhead = !nextAfterSpace(RBRACK);
    #                                                            lookingAhead = false;
    #                                                            return (!semanticLookAhead || scanWhitspaceToken());
    #                                                        }
    #                                                    }
    #                                                }
    #                                            }
    #                                        }
    #                                    }
    #                                }
    #                            }
    #                        }
    #                    }
    #                }
    #            }
    #        }
    #        return false;
  end

  def scan_resource_elements
    #        if (scanResourceElement()) {
    #            return true;
    #        }
    #        Token xsp;
    #        while (true) {
    #            xsp = scanPosition;
    #            if (scanResourceElement()) {
    #                scanPosition = xsp;
    #                break;
    #            }
    #        }
    #        return false;
  end

  def scan_link
    #        if (scanToken(LBRACK) || scanWhitspaceTokens() || scanLinkElement()) {
    #            return true;
    #        }
    #        Token xsp;
    #        while (true) {
    #            xsp = scanPosition;
    #            if (scanLinkElement()) {
    #                scanPosition = xsp;
    #                break;
    #            }
    #        }
    #        if (scanWhitspaceTokens() || scanToken(RBRACK)) {
    #            return true;
    #        }
    #        xsp = scanPosition;
    #        if (scanResourceUrl()) {
    #            scanPosition = xsp;
    #        }
    #        return false;
  end

  def scan_image
    #        if (scanToken(LBRACK) || scanWhitspaceTokens() || scanToken(IMAGE_LABEL) || scanImageElement()) {
    #            return true;
    #        }
    #        Token xsp;
    #        while (true) {
    #            xsp = scanPosition;
    #            if (scanImageElement()) {
    #                scanPosition = xsp;
    #                break;
    #            }
    #        }
    #        if (scanWhitspaceTokens() || scanToken(RBRACK)) {
    #            return true;
    #        }
    #        xsp = scanPosition;
    #        if (scanResourceUrl()) {
    #            scanPosition = xsp;
    #        }
    #        return false;
  end

  def scan_inline_element
    #        Token xsp = scanPosition;
    #        if (scanTextTokens()) {
    #            scanPosition = xsp;
    #            if (scanImage()) {
    #                scanPosition = xsp;
    #                if (scanLink()) {
    #                    scanPosition = xsp;
    #                    lookingAhead = true;
    #                    semanticLookAhead = multilineAhead(ASTERISK);
    #                    lookingAhead = false;
    #                    if (!semanticLookAhead || scanToken(ASTERISK)) {
    #                        scanPosition = xsp;
    #                        lookingAhead = true;
    #                        semanticLookAhead = multilineAhead(UNDERSCORE);
    #                        lookingAhead = false;
    #                        if (!semanticLookAhead || scanToken(UNDERSCORE)) {
    #                            scanPosition = xsp;
    #                            lookingAhead = true;
    #                            semanticLookAhead = multilineAhead(BACKTICK);
    #                            lookingAhead = false;
    #                            if (!semanticLookAhead || scanCodeMultiline()) {
    #                                scanPosition = xsp;
    #                                return scanLooseChar();
    #                            }
    #                        }
    #                    }
    #                }
    #            }
    #        }
    #        return false;
  end

  def scan_paragraph
    #        Token xsp;
    #        if (scanInlineElement()) {
    #            return true;
    #        }
    #        while (true) {
    #            xsp = scanPosition;
    #            if (scanInlineElement()) {
    #                scanPosition = xsp;
    #                break;
    #            }
    #        }
    #        return false;
  end

  def scan_whitspace_token
    #        Token xsp = scanPosition;
    #        if (scanToken(SPACE)) {
    #            scanPosition = xsp;
    #            if (scanToken(TAB)) {
    #                return true;
    #            }
    #        }
    #        return false;
  end

  def scan_fenced_code_block
    #        return scanToken(BACKTICK) || scanToken(BACKTICK) || scanToken(BACKTICK);
  end

  def scan_block_quote_empty_lines
    #        return scanBlockQuoteEmptyLine() || scanToken(EOL);
  end

  def scan_block_quote_empty_line
    #        if (scanToken(EOL) || scanWhitspaceTokens() || scanToken(GT) || scanWhitspaceTokens()) {
    #            return true;
    #        }
    #        Token xsp;
    #        while (true) {
    #            xsp = scanPosition;
    #            if (scanToken(GT) || scanWhitspaceTokens()) {
    #                scanPosition = xsp;
    #                break;
    #            }
    #        }
    #        return false;
  end

  def scan_for_headersigns
    #        if (scanToken(EQ)) {
    #            return true;
    #        }
    #        Token xsp;
    #        while (true) {
    #            xsp = scanPosition;
    #            if (scanToken(EQ)) {
    #                scanPosition = xsp;
    #                break;
    #            }
    #        }
    #        return false;
  end

  def scan_more_block_elements
    #        Token xsp = scanPosition;
    #        lookingAhead = true;
    #        semanticLookAhead = headingAhead(1);
    #        lookingAhead = false;
    #        if (!semanticLookAhead || scanForHeadersigns()) {
    #            scanPosition = xsp;
    #            if (scanToken(GT)) {
    #                scanPosition = xsp;
    #                if (scanToken(DASH)) {
    #                    scanPosition = xsp;
    #                    if (scanToken(DIGITS) || scanToken(DOT)) {
    #                        scanPosition = xsp;
    #                        if (scanFencedCodeBlock()) {
    #                            scanPosition = xsp;
    #                            return scanParagraph();
    #                        }
    #                    }
    #                }
    #            }
    #        }
    #        return false;
  end

  def scan_token(kind)
    #        if (scanPosition == lastPosition) {
    #            lookAhead--;
    #            if (scanPosition.next == null) {
    #                lastPosition = scanPosition = scanPosition.next = tm.getNextToken();
    #            } else {
    #                lastPosition = scanPosition = scanPosition.next;
    #            }
    #        } else {
    #            scanPosition = scanPosition.next;
    #        }
    #        if (scanPosition.kind != kind) {
    #            return true;
    #        }
    #        if (lookAhead == 0 && scanPosition == lastPosition) {
    #            throw lookAheadSuccess;
    #        }
    #        return false;
  end

  def get_next_token_kind
    #        if (nextTokenKind != -1) {
    #            return nextTokenKind;
    #        } else if ((nextToken = token.next) == null) {
    #            token.next = tm.getNextToken();
    #            return (nextTokenKind = token.next.kind);
    #        }
    #        return (nextTokenKind = nextToken.kind);
  end

  def consume_token(kind)
    #        Token old = token;
    #        if (token.next != null) {
    #            token = token.next;
    #        } else {
    #            token = token.next = tm.getNextToken();
    #        }
    #        nextTokenKind = -1;
    #        if (token.kind == kind) {
    #            return token;
    #        }
    #        token = old;
    #        return token;
  end

  def get_token(index)
    #        Token t = lookingAhead ? scanPosition : token;
    #        for (int i = 0; i < index; i++) {
    #            if (t.next != null) {
    #                t = t.next;
    #            } else {
    #                t = t.next = tm.getNextToken();
    #            }
    #        }
    #        return t;
  end

  def setModules(modules)
    this.modules = Arrays.asList(modules);
    #    }
    #
  end

end
