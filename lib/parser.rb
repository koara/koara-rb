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
    #        return parseReader(new StringReader(text));
  end

  def parseFile(file)
    #      if(!file.getName().toLowerCase().endsWith(".kd")) {
    #        throw new IllegalArgumentException("Can only parse files with extension .kd");
    #      }
    #        return parseReader(new FileReader(file));
  end

  def parseReader(reader)
    #        cs = new CharStream(reader);
    #        tm = new TokenManager(cs);
    #        token = new Token();
    #        tree = new TreeState();
    #        nextTokenKind = -1;
    #
    #        Document document = new Document();
    #        tree.openScope();
    #        while (getNextTokenKind() == EOL) {
    #            consumeToken(EOL);
    #        }
    #
    #        whiteSpace();
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
    #        consumeToken(EOF);
    #        tree.closeScope(document);
    #        return document;
  end

  #
  def blockElement()
    @currentBlockLevel += 1
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
    @currentBlockLevel -= 1
  end

  def heading()
    #        Heading heading = new Heading();
    #        tree.openScope();
    #        int headingLevel = 0;
    #
    #        while (getNextTokenKind() == EQ) {
    #            consumeToken(EQ);
    #            headingLevel++;
    #        }
    #        whiteSpace();
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
    #        heading.setValue(headingLevel);
    #        tree.closeScope(heading);
  end

  def blockQuote()
    #        BlockQuote blockQuote = new BlockQuote();
    #        tree.openScope();
    #        currentQuoteLevel++;
    #        consumeToken(GT);
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
    #        currentQuoteLevel--;
    #        tree.closeScope(blockQuote);
  end

  def blockQuotePrefix()
    #        int i = 0;
    #        do {
    #            consumeToken(GT);
    #            whiteSpace();
    #        } while (++i < currentQuoteLevel);
  end

  def blockQuoteEmptyLine()
    #        consumeToken(EOL);
    #        whiteSpace();
    #        do {
    #            consumeToken(GT);
    #            whiteSpace();
    #        } while (getNextTokenKind() == GT);
  end

  def unorderedList()
    #        ListBlock list = new ListBlock(false);
    #        tree.openScope();
    #        int listBeginColumn = unorderedListItem();
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
    #        tree.closeScope(list);
  end

  def unorderedListItem()
    #        ListItem listItem = new ListItem();
    #        tree.openScope();
    #
    #        Token t = consumeToken(DASH);
    #        whiteSpace();
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
    #        tree.closeScope(listItem);
    #        return t.beginColumn;
  end

  def orderedList()
    #        ListBlock list = new ListBlock(true);
    #        tree.openScope();
    #        int listBeginColumn = orderedListItem();
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
    #        tree.closeScope(list);
  end

  def orderedListItem()
    #        ListItem listItem = new ListItem();
    #        tree.openScope();
    #        Token t = consumeToken(DIGITS);
    #        consumeToken(DOT);
    #        whiteSpace();
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
    #        listItem.setNumber(Integer.valueOf(t.image));
    #        tree.closeScope(listItem);
    #        return t.beginColumn;
  end

  def fencedCodeBlock()
    #        CodeBlock codeBlock = new CodeBlock();
    #        tree.openScope();
    #        StringBuilder s = new StringBuilder();
    #        int beginColumn = consumeToken(BACKTICK).beginColumn;
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
    #        int kind = getNextTokenKind();
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
    #        if (fencesAhead()) {
    #            consumeToken(EOL);
    #            whiteSpace();
    #            while (getNextTokenKind() == BACKTICK) {
    #                consumeToken(BACKTICK);
    #            }
    #        }
    #        codeBlock.setValue(s.toString());
    #        tree.closeScope(codeBlock);
  end

  def paragraph()
    #        BlockElement paragraph = modules.contains("paragraphs") ? new Paragraph() : new BlockElement();
    #        tree.openScope();
    #        inline();
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
    #        tree.closeScope(paragraph);
  end

  def text()
    #        Text text = new Text();
    #        tree.openScope();
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
    #        tree.closeScope(text);
  end

  def image()
    #        Image image = new Image();
    #        tree.openScope();
    #        String ref = "";
    #        consumeToken(LBRACK);
    #        whiteSpace();
    #        consumeToken(IMAGE_LABEL);
    #        whiteSpace();
    #        while (imageHasAnyElements()) {
    #            if (hasTextAhead()) {
    #                resourceText();
    #            } else {
    #                looseChar();
    #            }
    #        }
    #        whiteSpace();
    #        consumeToken(RBRACK);
    #        if (hasResourceUrlAhead()) {
    #            ref = resourceUrl();
    #        }
    #        image.setValue(ref);
    #        tree.closeScope(image);
  end

  def link()
    #        Link link = new Link();
    #        tree.openScope();
    #        String ref = "";
    #        consumeToken(LBRACK);
    #        whiteSpace();
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
    #        whiteSpace();
    #        consumeToken(RBRACK);
    #        if (hasResourceUrlAhead()) {
    #            ref = resourceUrl();
    #        }
    #        link.setValue(ref);
    #        tree.closeScope(link);
  end

  def strong()
    #        Strong strong = new Strong();
    #        tree.openScope();
    #        consumeToken(ASTERISK);
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
    #        consumeToken(ASTERISK);
    #        tree.closeScope(strong);
  end

  def em()
    #        Em em = new Em();
    #        tree.openScope();
    #        consumeToken(UNDERSCORE);
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
    #        consumeToken(UNDERSCORE);
    #        tree.closeScope(em);
  end

  def code()
    #        Code code = new Code();
    #        tree.openScope();
    #        consumeToken(BACKTICK);
    #        codeText();
    #        consumeToken(BACKTICK);
    #        tree.closeScope(code);
  end

  def codeText()
    #        Text text = new Text();
    #        tree.openScope();
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
    #        tree.closeScope(text);
  end

  def looseChar()
    #        Text text = new Text();
    #        tree.openScope();
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
    #        tree.closeScope(text);
  end

  def lineBreak()
    #        LineBreak linebreak = new LineBreak();
    #        tree.openScope();
    #        while (getNextTokenKind() == SPACE || getNextTokenKind() == TAB) {
    #            consumeToken(getNextTokenKind());
    #        }
    #        consumeToken(EOL);
    #        tree.closeScope(linebreak);
  end

  def levelWhiteSpace(threshold)
    #        int currentPos = 1;
    #        while (getNextTokenKind() == GT) {
    #            consumeToken(getNextTokenKind());
    #        }
    #        while ((getNextTokenKind() == SPACE || getNextTokenKind() == TAB) && currentPos < (threshold - 1)) {
    #            currentPos = consumeToken(getNextTokenKind()).beginColumn;
    #        }
  end

  def codeLanguage()
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

  def inline()
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

  def resourceText()
    #        Text text = new Text();
    #        tree.openScope();
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
    #        tree.closeScope(text);
  end

  def resourceUrl()
    #        consumeToken(LPAREN);
    #        whiteSpace();
    #        String ref = resourceUrlText();
    #        whiteSpace();
    #        consumeToken(RPAREN);
    #        return ref;
  end

  def resourceUrlText()
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

  def strongMultiline()
    #        Strong strong = new Strong();
    #        tree.openScope();
    #        consumeToken(ASTERISK);
    #        strongMultilineContent();
    #        while (textAhead()) {
    #            lineBreak();
    #            whiteSpace();
    #            strongMultilineContent();
    #        }
    #        consumeToken(ASTERISK);
    #        tree.closeScope(strong);
  end

  def strongMultilineContent()
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

  def strongWithinEmMultiline()
    #        Strong strong = new Strong();
    #        tree.openScope();
    #        consumeToken(ASTERISK);
    #        strongWithinEmMultilineContent();
    #        while (textAhead()) {
    #            lineBreak();
    #            strongWithinEmMultilineContent();
    #        }
    #        consumeToken(ASTERISK);
    #        tree.closeScope(strong);
  end

  def strongWithinEmMultilineContent()
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

  def strongWithinEm()
    #        Strong strong = new Strong();
    #        tree.openScope();
    #        consumeToken(ASTERISK);
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
    #        consumeToken(ASTERISK);
    #        tree.closeScope(strong);
  end

  def emMultiline()
    #        Em em = new Em();
    #        tree.openScope();
    #        consumeToken(UNDERSCORE);
    #        emMultilineContent();
    #        while (textAhead()) {
    #            lineBreak();
    #            whiteSpace();
    #            emMultilineContent();
    #        }
    #        consumeToken(UNDERSCORE);
    #        tree.closeScope(em);
  end

  def emMultilineContent()
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

  def emWithinStrongMultiline()
    #        Em em = new Em();
    #        tree.openScope();
    #        consumeToken(UNDERSCORE);
    #        emWithinStrongMultilineContent();
    #        while (textAhead()) {
    #            lineBreak();
    #            emWithinStrongMultilineContent();
    #        }
    #        consumeToken(UNDERSCORE);
    #        tree.closeScope(em);
  end

  def emWithinStrongMultilineContent()
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

  def emWithinStrong()
    #        Em em = new Em();
    #        tree.openScope();
    #        consumeToken(UNDERSCORE);
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
    #        consumeToken(UNDERSCORE);
    #        tree.closeScope(em);
  end

  def codeMultiline()
    #        Code code = new Code();
    #        tree.openScope();
    #        consumeToken(BACKTICK);
    #        codeText();
    #        while (textAhead()) {
    #            lineBreak();
    #            whiteSpace();
    #            while (getNextTokenKind() == GT) {
    #                consumeToken(GT);
    #                whiteSpace();
    #            }
    #            codeText();
    #        }
    #        consumeToken(BACKTICK);
    #        tree.closeScope(code);
  end

  def whiteSpace()
    #        while (getNextTokenKind() == SPACE || getNextTokenKind() == TAB) {
    #            consumeToken(getNextTokenKind());
    #        }
  end

  def hasAnyBlockElementsAhead()
    #        try {
    #            lookAhead = 1;
    #            lastPosition = scanPosition = token;
    #            return !scanMoreBlockElements();
    #        } catch (LookaheadSuccess ls) {
    #            return true;
    #        }
  end

  def blockAhead(blockBeginColumn)
    #        int quoteLevel;
    #
    #        if (getNextTokenKind() == EOL) {
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
    #        }
    #        return false;
  end

  def multilineAhead(token)
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
    #        return false;
  end

  def fencesAhead()
    #        int i = skip(2, SPACE, TAB, GT);
    #        if (getToken(i).kind == BACKTICK && getToken(i + 1).kind == BACKTICK && getToken(i + 2).kind == BACKTICK) {
    #            i = skip(i + 3, SPACE, TAB);
    #            return getToken(i).kind == EOL || getToken(i).kind == EOF;
    #        }
    #        return false;
  end

  def headingAhead(offset)
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

  def listItemAhead(listBeginColumn, ordered)
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
    #        return false;
  end

  def textAhead()
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
    #        return false;
  end

  def nextAfterSpace(tokens)
    #        int i = skip(1, SPACE, TAB);
    #        return Arrays.asList(tokens).contains(getToken(i).kind);
  end

  def newQuoteLevel(offset)
    #        int quoteLevel = 0;
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

  def hasOrderedListAhead()
    #        lookAhead = 2;
    #        lastPosition = scanPosition = token;
    #        try {
    #            return !scanToken(DIGITS) && !scanToken(DOT);
    #        } catch (LookaheadSuccess ls) {
    #            return true;
    #        }
  end

  def hasFencedCodeBlockAhead()
    #        lookAhead = 3;
    #        lastPosition = scanPosition = token;
    #        try {
    #            return !scanFencedCodeBlock();
    #        } catch (LookaheadSuccess ls) {
    #            return true;
    #        }
  end

  def headingHasInlineElementsAhead()
    #        lookAhead = 1;
    #        lastPosition = scanPosition = token;
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
    #            return true;
    #        } catch (LookaheadSuccess ls) {
    #            return true;
    #        }
  end

  def hasTextAhead()
    #        lookAhead = 1;
    #        lastPosition = scanPosition = token;
    #        try {
    #            return !scanTextTokens();
    #        } catch (LookaheadSuccess ls) {
    #            return true;
    #        }
  end

  def hasImageAhead()
    #        lookAhead = 2147483647;
    #        lastPosition = scanPosition = token;
    #        try {
    #            return !scanImage();
    #        } catch (LookaheadSuccess ls) {
    #            return true;
    #        }
  end

  def blockQuoteHasEmptyLineAhead()
    #        lookAhead = 2147483647;
    #        lastPosition = scanPosition = token;
    #        try {
    #            return !scanBlockQuoteEmptyLine();
    #        } catch (LookaheadSuccess ls) {
    #            return true;
    #        }
  end

  def hasStrongAhead()
    #        lookAhead = 2147483647;
    #        lastPosition = scanPosition = token;
    #        try {
    #            return !scanStrong();
    #        } catch (LookaheadSuccess ls) {
    #            return true;
    #        }
  end

  def hasEmAhead()
    #        lookAhead = 2147483647;
    #        lastPosition = scanPosition = token;
    #        try {
    #            return !scanEm();
    #        } catch (LookaheadSuccess ls) {
    #            return true;
    #        }
  end

  def hasCodeAhead()
    #        lookAhead = 2147483647;
    #        lastPosition = scanPosition = token;
    #        try {
    #            return !scanCode();
    #        } catch (LookaheadSuccess ls) {
    #            return true;
    #        }
  end

  def blockQuoteHasAnyBlockElementseAhead()
    #        lookAhead = 1;
    #        lastPosition = scanPosition = token;
    #        try {
    #            return !scanMoreBlockElements();
    #        } catch (LookaheadSuccess ls) {
    #            return true;
    #        }
  end

  def hasBlockQuoteEmptyLinesAhead()
    #        lookAhead = 2147483647;
    #        lastPosition = scanPosition = token;
    #        try {
    #            return !scanBlockQuoteEmptyLines();
    #        } catch (LookaheadSuccess ls) {
    #            return true;
    #        }
  end

  def listItemHasInlineElements()
    #        lookAhead = 1;
    #        lastPosition = scanPosition = token;
    #        try {
    #            return !scanMoreBlockElements();
    #        } catch (LookaheadSuccess ls) {
    #            return true;
    #        }
  end

  def hasInlineTextAhead()
    #        lookAhead = 1;
    #        lastPosition = scanPosition = token;
    #        try {
    #            return !scanTextTokens();
    #        } catch (LookaheadSuccess ls) {
    #            return true;
    #        }
  end

  def hasInlineElementAhead()
    #        lookAhead = 1;
    #        lastPosition = scanPosition = token;
    #        try {
    #            return !scanInlineElement();
    #        } catch (LookaheadSuccess ls) {
    #            return true;
    #        }
  end

  def imageHasAnyElements()
    #        lookAhead = 1;
    #        lastPosition = scanPosition = token;
    #        try {
    #            return !scanImageElement();
    #        } catch (LookaheadSuccess ls) {
    #            return true;
    #        }
  end

  def hasResourceTextAhead()
    #        lookAhead = 1;
    #        lastPosition = scanPosition = token;
    #        try {
    #            return !scanResourceElements();
    #        } catch (LookaheadSuccess ls) {
    #            return true;
    #        }
  end

  def linkHasAnyElements()
    #        lookAhead = 1;
    #        lastPosition = scanPosition = token;
    #        try {
    #            return !scanLinkElement();
    #        } catch (LookaheadSuccess ls) {
    #            return true;
    #        }
  end

  def hasResourceUrlAhead()
    #        lookAhead = 2147483647;
    #        lastPosition = scanPosition = token;
    #        try {
    #            return !scanResourceUrl();
    #        } catch (LookaheadSuccess ls) {
    #            return true;
    #        }
  end

  def resourceHasElementAhead()
    #        lookAhead = 2;
    #        lastPosition = scanPosition = token;
    #        try {
    #            return !scanResourceElement();
    #        } catch (LookaheadSuccess ls) {
    #            return true;
    #        }
  end

  def resourceTextHasElementsAhead()
    #        lookAhead = 1;
    #        lastPosition = scanPosition = token;
    #        try {
    #            return !scanResourceTextElement();
    #        } catch (LookaheadSuccess ls) {
    #            return true;
    #        }
  end

  def hasEmWithinStrongMultiline()
    #        lookAhead = 2147483647;
    #        lastPosition = scanPosition = token;
    #        try {
    #            return !scanEmWithinStrongMultiline();
    #        } catch (LookaheadSuccess ls) {
    #            return true;
    #        }
  end

  def strongMultilineHasElementsAhead()
    #        lookAhead = 1;
    #        lastPosition = scanPosition = token;
    #        try {
    #            return !scanStrongMultilineElements();
    #        } catch (LookaheadSuccess ls) {
    #            return true;
    #        }
  end

  def strongWithinEmMultilineHasElementsAhead()
    #        lookAhead = 1;
    #        lastPosition = scanPosition = token;
    #        try {
    #            return !scanStrongWithinEmMultilineElements();
    #        } catch (LookaheadSuccess ls) {
    #            return true;
    #        }
  end

  def hasImage()
    #        lookAhead = 2147483647;
    #        lastPosition = scanPosition = token;
    #        try {
    #            return !scanImage();
    #        } catch (LookaheadSuccess ls) {
    #            return true;
    #        }
  end

  def hasLinkAhead()
    #        lookAhead = 2147483647;
    #        lastPosition = scanPosition = token;
    #        try {
    #            return !scanLink();
    #        } catch (LookaheadSuccess ls) {
    #            return true;
    #        }
  end

  def strongEmWithinStrongAhead()
    #        lookAhead = 2147483647;
    #        lastPosition = scanPosition = token;
    #        try {
    #            return !scanEmWithinStrong();
    #        } catch (LookaheadSuccess ls) {
    #            return true;
    #        }
  end

  def strongHasElements()
    #        lookAhead = 1;
    #        lastPosition = scanPosition = token;
    #        try {
    #            return !scanStrongElements();
    #        } catch (LookaheadSuccess ls) {
    #            return true;
    #        }
  end

  def strongWithinEmHasElementsAhead()
    #        lookAhead = 1;
    #        lastPosition = scanPosition = token;
    #        try {
    #            return !scanStrongWithinEmElements();
    #        } catch (LookaheadSuccess ls) {
    #            return true;
    #        }
  end

  def hasStrongWithinEmMultilineAhead()
    #        lookAhead = 2147483647;
    #        lastPosition = scanPosition = token;
    #        try {
    #            return !scanStrongWithinEmMultiline();
    #        } catch (LookaheadSuccess ls) {
    #            return true;
    #        }
  end

  def emMultilineContentHasElementsAhead()
    #        lookAhead = 1;
    #        lastPosition = scanPosition = token;
    #        try {
    #            return !scanEmMultilineContentElements();
    #        } catch (LookaheadSuccess ls) {
    #            return true;
    #        }
  end

  def emWithinStrongMultilineContentHasElementsAhead()
    #        lookAhead = 1;
    #        lastPosition = scanPosition = token;
    #        try {
    #            return !scanEmWithinStrongMultilineContent();
    #        } catch (LookaheadSuccess ls) {
    #            return true;
    #        }
  end

  def emHasStrongWithinEm()
    #        lookAhead = 2147483647;
    #        lastPosition = scanPosition = token;
    #        try {
    #            return !scanStrongWithinEm();
    #        } catch (LookaheadSuccess ls) {
    #            return true;
    #        }
  end

  def emHasElements()
    #        lookAhead = 1;
    #        lastPosition = scanPosition = token;
    #        try {
    #            return !scanEmElements();
    #        } catch (LookaheadSuccess ls) {
    #            return true;
    #        }
  end

  def emWithinStrongHasElementsAhead()
    #        lookAhead = 1;
    #        lastPosition = scanPosition = token;
    #        try {
    #            return !scanEmWithinStrongElements();
    #        } catch (LookaheadSuccess ls) {
    #            return true;
    #        }
  end

  def codeTextHasAnyTokenAhead()
    #        lookAhead = 1;
    #        lastPosition = scanPosition = token;
    #        try {
    #            return !scanCodeTextTokens();
    #        } catch (LookaheadSuccess ls) {
    #            return true;
    #        }
  end

  def textHasTokensAhead()
    #        lookAhead = 1;
    #        lastPosition = scanPosition = token;
    #        try {
    #            return !scanText();
    #        } catch (LookaheadSuccess ls) {
    #            return true;
    #        }
  end

  def scanLooseChar()
    #        Token xsp = scanPosition;
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

  def scanText()
    #        Token xsp = scanPosition;
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
    #        return false;
  end

  def scanTextTokens()
    #        if (scanText()) {
    #            return true;
    #        }
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

  def scanCodeTextTokens()
    #        Token xsp = scanPosition;
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

  def scanCode()
    #        return scanToken(BACKTICK) || scanCodeTextTokensAhead() || scanToken(BACKTICK);
  end

  def scanCodeMultiline()
    #        if (scanToken(BACKTICK) || scanCodeTextTokensAhead()) {
    #            return true;
    #        }
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

  def scanCodeTextTokensAhead()
    #        if (scanCodeTextTokens()) {
    #            return true;
    #        }
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

  def hasCodeTextOnNextLineAhead()
    #        if (scanWhitespaceTokenBeforeEol()) {
    #            return true;
    #        }
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

  def scanWhitspaceTokens()
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

  def scanWhitespaceTokenBeforeEol()
    #        return scanWhitspaceTokens() || scanToken(EOL);
  end

  def scanEmWithinStrongElements()
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

  def scanEmWithinStrong()
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

  def scanEmElements()
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
    #        return false;
  end

  def scanEm()
    #        if (scanToken(UNDERSCORE) || scanEmElements()) {
    #            return true;
    #        }
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

  def scanEmWithinStrongMultilineContent()
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

  def hasNoEmWithinStrongMultilineContentAhead()
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

  def scanEmWithinStrongMultiline()
  #        if (scanToken(UNDERSCORE) || hasNoEmWithinStrongMultilineContentAhead()) {
  #            return true;
  #        }
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
  
  def scanEmMultilineContentElements()
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
  
  def scanStrongWithinEmElements()
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
  
  def scanStrongWithinEm()
  #        if (scanToken(ASTERISK) || scanStrongWithinEmElements()) {
  #            return true;
  #        }
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
  
 def scanStrongElements()
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
  #        return false;
 end
  
  def scanStrong()
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
  #        return scanToken(ASTERISK);
  end
  
  def scanStrongWithinEmMultilineElements()
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
  
  def scanForMoreStrongWithinEmMultilineElements()
  #        if (scanStrongWithinEmMultilineElements()) {
  #            return true;
  #        }
  #        Token xsp;
  #        while (true) {
  #            xsp = scanPosition;
  #            if (scanStrongWithinEmMultilineElements()) {
  #                scanPosition = xsp;
  #                break;
  #            }
  #        }
  #        return false;
  end
  
  def scanStrongWithinEmMultiline()
  #        if (scanToken(ASTERISK) || scanForMoreStrongWithinEmMultilineElements()) {
  #            return true;
  #        }
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
  
  def scanStrongMultilineElements()
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
  
  def scanResourceTextElement()
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
  
  def scanImageElement()
  #        Token xsp = scanPosition;
  #        if (scanResourceElements()) {
  #            scanPosition = xsp;
  #            if (scanLooseChar()) {
  #                return true;
  #            }
  #        }
  #        return false;
  end
  
  def scanResourceTextElements()
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
  
  def scanResourceUrl()
  #        return scanToken(LPAREN) || scanWhitspaceTokens() || scanResourceTextElements() || scanWhitspaceTokens()
  #                || scanToken(RPAREN);
  end
  
 def scanLinkElement()
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
  
  def scanResourceElement()
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
  
  def scanResourceElements()
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
  
  def scanLink()
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
  
 def scanImage()
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
  
  def scanInlineElement()
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
  
  def scanParagraph()
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
  
  def scanWhitspaceToken()
  #        Token xsp = scanPosition;
  #        if (scanToken(SPACE)) {
  #            scanPosition = xsp;
  #            if (scanToken(TAB)) {
  #                return true;
  #            }
  #        }
  #        return false;
  end
  
  def scanFencedCodeBlock()
  #        return scanToken(BACKTICK) || scanToken(BACKTICK) || scanToken(BACKTICK);
  end
  
  def scanBlockQuoteEmptyLines()
  #        return scanBlockQuoteEmptyLine() || scanToken(EOL);
  end
  
  def scanBlockQuoteEmptyLine()
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
  
  def scanForHeadersigns()
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
  
  def scanMoreBlockElements()
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
  
  def scanToken(kind)
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
  
  def getNextTokenKind()
  #        if (nextTokenKind != -1) {
  #            return nextTokenKind;
  #        } else if ((nextToken = token.next) == null) {
  #            token.next = tm.getNextToken();
  #            return (nextTokenKind = token.next.kind);
  #        }
  #        return (nextTokenKind = nextToken.kind);
  end
  
  def consumeToken(kind)
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
  
  def getToken(index)
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
  #}
  
end
