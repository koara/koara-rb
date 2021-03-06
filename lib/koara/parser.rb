# encoding: utf-8
require 'stringio'
require 'koara/charstream'
require 'koara/lookahead_success'
require 'koara/token_manager'
require 'koara/tree_state'
require 'koara/ast/blockelement'
require 'koara/ast/blockquote'
require 'koara/ast/code'
require 'koara/ast/codeblock'
require 'koara/ast/document'
require 'koara/ast/em'
require 'koara/ast/heading'
require 'koara/ast/image'
require 'koara/ast/paragraph'
require 'koara/ast/text'
require 'koara/ast/linebreak'
require 'koara/ast/link'
require 'koara/ast/listblock'
require 'koara/ast/listitem'
require 'koara/ast/strong'
require 'koara/io/filereader'

module Koara
  class Parser
    attr_reader :modules

    def initialize
      @current_block_level = 0
      @current_quote_level = 0
      @look_ahead_success = Koara::LookaheadSuccess.new
      @modules = %w(paragraphs headings lists links images formatting blockquotes code)
    end

    def parse(text)
      return parse_reader(Koara::Io::StringReader.new(text))
    end

    def parse_file(file)


      if File.basename(file).downcase.reverse[0, 3].reverse.to_s != '.kd'
        raise(ArgumentError, "Can only parse files with extension .kd")
      end
      parse_reader(Io::FileReader.new(file))
    end

    def parse_reader(reader)
      @cs = CharStream.new(reader)
      @tm = TokenManager.new(@cs)
      @token = Token.new
      @tree = TreeState.new
      @next_token_kind = -1
      document = Ast::Document.new
      @tree.open_scope

      while get_next_token_kind == TokenManager::EOL
        consume_token(TokenManager::EOL)
      end
      white_space
      if has_any_block_elements_ahead
        block_element
        while block_ahead(0)
          while get_next_token_kind == TokenManager::EOL
            consume_token(TokenManager::EOL)
            white_space
          end
          block_element
        end
        while get_next_token_kind == TokenManager::EOL
          consume_token(TokenManager::EOL)
        end
        white_space
      end
      consume_token(Koara::TokenManager::EOF)
      @tree.close_scope(document)
      document
    end

    def block_element
      @current_block_level += 1
      if modules.include?('headings') && heading_ahead(1)
        heading
      elsif modules.include?('blockquotes') && get_next_token_kind == TokenManager::GT
        block_quote
      elsif modules.include?('lists') && get_next_token_kind == TokenManager::DASH
        unordered_list
      elsif modules.include?('lists') && has_ordered_list_ahead
        ordered_list
      elsif modules.include?('code') && has_fenced_code_block_ahead
        fenced_code_block
      else
        paragraph
      end
      @current_block_level -= 1
    end

    def heading
      heading = Ast::Heading.new
      @tree.open_scope
      heading_level = 0

      while get_next_token_kind == TokenManager::EQ
        consume_token(TokenManager::EQ)
        heading_level += 1
      end
      white_space
      while heading_has_inline_elements_ahead
        if has_text_ahead
          text
        elsif modules.include?('images') && has_image_ahead
          image
        elsif modules.include?('links') && has_link_ahead
          link
        elsif modules.include?('formatting') && has_strong_ahead
          strong
        elsif modules.include?('formatting') && has_em_ahead
          em
        elsif modules.include?('code') && has_code_ahead
          code
        else
          loose_char
        end
      end
      heading.value = heading_level
      @tree.close_scope(heading)
    end

    def block_quote
      blockquote = Ast::BlockQuote.new
      @tree.open_scope
      @current_quote_level += 1
      consume_token(TokenManager::GT)
      while block_quote_has_empty_line_ahead
        block_quote_empty_line
      end
      white_space
      if block_quote_has_any_block_elements_ahead
        block_element
        while block_ahead(0)
          while get_next_token_kind == TokenManager::EOL
            consume_token(TokenManager::EOL)
            white_space
            block_quote_prefix
          end
          block_element
        end
      end
      while has_block_quote_empty_lines_ahead
        block_quote_empty_line
      end
      @current_quote_level -= 1
      @tree.close_scope(blockquote)
    end

    def block_quote_prefix
      i = 0
      loop do
        consume_token(TokenManager::GT)
        white_space
        i+=1
        break if (i >= @current_quote_level)
      end
    end

    def block_quote_empty_line
      consume_token(TokenManager::EOL)
      white_space
      loop do
        consume_token(TokenManager::GT)
        white_space
        break if (get_next_token_kind != TokenManager::GT)
      end
    end

    def unordered_list
      list = Ast::ListBlock.new(false)
      @tree.open_scope
      list_begin_column = unordered_list_item
      while list_item_ahead(list_begin_column, false)
        while get_next_token_kind == TokenManager::EOL
          consume_token(TokenManager::EOL)
        end
        white_space
        if @current_quote_level > 0
          block_quote_prefix
        end
        unordered_list_item
      end
      @tree.close_scope(list)
    end

    def unordered_list_item
      list_item = Ast::ListItem.new
      @tree.open_scope

      t = consume_token(TokenManager::DASH)
      white_space
      if list_item_has_inline_elements
        block_element
        while block_ahead(t.begin_column)
          while get_next_token_kind == TokenManager::EOL
            consume_token(TokenManager::EOL)
            white_space
            if @current_quote_level > 0
              block_quote_prefix
            end
          end
          block_element
        end
      end
      @tree.close_scope(list_item)
      t.begin_column
    end

    def ordered_list
      list = Ast::ListBlock.new(true)
      @tree.open_scope
      list_begin_column = ordered_list_item
      while list_item_ahead(list_begin_column, true)
        while get_next_token_kind == TokenManager::EOL
          consume_token(TokenManager::EOL)
        end
        white_space
        if @current_quote_level > 0
          block_quote_prefix
        end
        ordered_list_item
      end
      @tree.close_scope(list)
    end

    def ordered_list_item
      list_item = Ast::ListItem.new
      @tree.open_scope
      t = consume_token(TokenManager::DIGITS)
      consume_token(TokenManager::DOT)
      white_space
      if list_item_has_inline_elements
        block_element
        while block_ahead(t.begin_column)
          while get_next_token_kind == TokenManager::EOL
            consume_token(TokenManager::EOL)
            white_space
            if @current_quote_level > 0
              block_quote_prefix
            end
          end
          block_element
        end
      end
      list_item.number = t.image
      @tree.close_scope(list_item)
      t.begin_column
    end

    def fenced_code_block
      code_block = Ast::CodeBlock.new
      @tree.open_scope
      s = StringIO.new('')
      begin_column = consume_token(TokenManager::BACKTICK).begin_column
      loop do
        consume_token(TokenManager::BACKTICK)
        break if (get_next_token_kind != TokenManager::BACKTICK)
      end
      white_space
      if get_next_token_kind == TokenManager::CHAR_SEQUENCE
        code_block.language = code_language
      end
      if get_next_token_kind != TokenManager::EOF && !fences_ahead
        consume_token(TokenManager::EOL)
        level_white_space(begin_column)
      end

      kind = get_next_token_kind
      while kind != TokenManager::EOF && ((kind != TokenManager::EOL && kind != TokenManager::BACKTICK) || !fences_ahead)

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
            if !next_after_space(TokenManager::EOL, TokenManager::EOF)
              case kind
                when TokenManager::SPACE
                  s << consume_token(TokenManager::SPACE).image
                when TokenManager::TAB
                  consume_token(TokenManager::TAB)
                  s << '    '
              end
            elsif !fences_ahead
              consume_token(TokenManager::EOL)
              s << "\n"
              level_white_space(begin_column)
            end
        end
        kind = get_next_token_kind
      end
      if fences_ahead
        consume_token(TokenManager::EOL)
        block_quote_prefix
        white_space
        while get_next_token_kind == TokenManager::BACKTICK
          consume_token(TokenManager::BACKTICK)
        end
      end
      code_block.value = s.string
      @tree.close_scope(code_block)
    end

    def paragraph
      paragraph = @modules.include?('paragraphs') ? Ast::Paragraph.new : Ast::BlockElement.new
      @tree.open_scope
      inline
      while text_ahead
        line_break
        white_space
        if modules.include?('blockquotes')
          while get_next_token_kind == TokenManager::GT
            consume_token(TokenManager::GT)
            white_space
          end
        end
        inline
      end
      @tree.close_scope(paragraph)
    end

    def text
      text = Ast::Text.new
      @tree.open_scope
      s = StringIO.new('')
      while text_has_tokens_ahead
        case get_next_token_kind
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
          when TokenManager::GT
            s << consume_token(TokenManager::GT).image
          when TokenManager::IMAGE_LABEL
            s << consume_token(TokenManager::IMAGE_LABEL).image
          when TokenManager::LPAREN
            s << consume_token(TokenManager::LPAREN).image
          when TokenManager::LT
            s << consume_token(TokenManager::LT).image
          when TokenManager::RBRACK
            s << consume_token(TokenManager::RBRACK).image
          when TokenManager::RPAREN
            s << consume_token(TokenManager::RPAREN).image
          else
            case get_next_token_kind
              when TokenManager::SPACE
                s << consume_token(TokenManager::SPACE).image
              when TokenManager::TAB
                consume_token(TokenManager::TAB)
                s << '    '
            end unless next_after_space(TokenManager::EOL, TokenManager::EOF)
        end
      end
      text.value = s.string
      @tree.close_scope(text)
    end

    def image
      image = Ast::Image.new
      @tree.open_scope
      ref = ''
      consume_token(TokenManager::LBRACK)
      white_space
      consume_token(TokenManager::IMAGE_LABEL)
      white_space
      while image_has_any_elements
        if has_text_ahead
          resource_text
        else
          loose_char
        end
      end
      white_space
      consume_token(TokenManager::RBRACK)
      if has_resource_url_ahead
        ref = resource_url
      end
      image.value = ref
      @tree.close_scope(image)
    end

    def link
      link = Ast::Link.new
      @tree.open_scope
      ref = ''
      consume_token(TokenManager::LBRACK)
      white_space
      while link_has_any_elements
        if modules.include?('images') && has_image_ahead
          image
        elsif modules.include?('formatting') && has_strong_ahead
          strong
        elsif modules.include?('formatting') && has_em_ahead
          em
        elsif modules.include?('code') && has_code_ahead
          code
        elsif has_resource_text_ahead
          resource_text
        else
          loose_char
        end
      end
      white_space
      consume_token(TokenManager::RBRACK)
      if has_resource_url_ahead
        ref = resource_url
      end
      link.value = ref
      @tree.close_scope(link)
    end

    def strong
      strong = Ast::Strong.new
      @tree.open_scope
      consume_token(TokenManager::ASTERISK)
      while strong_has_elements
        if has_text_ahead
          text
        elsif modules.include?('images') && has_image
          image
        elsif modules.include?('links') && has_link_ahead
          link
        elsif modules.include?('code') && multiline_ahead(TokenManager::BACKTICK)
          code_multiline
        elsif strong_em_within_strong_ahead
          em_within_strong
        else
          case get_next_token_kind
            when TokenManager::BACKTICK
              @tree.add_single_value(Ast::Text.new, consume_token(TokenManager::BACKTICK))
            when TokenManager::LBRACK
              @tree.add_single_value(Ast::Text.new, consume_token(TokenManager::LBRACK))
            when TokenManager::UNDERSCORE
              @tree.add_single_value(Ast::Text.new, consume_token(TokenManager::UNDERSCORE))
            else
              break
          end
        end
      end
      consume_token(TokenManager::ASTERISK)
      @tree.close_scope(strong)
    end

    def em
      em = Ast::Em.new
      @tree.open_scope
      consume_token(TokenManager::UNDERSCORE)
      while em_has_elements
        if has_text_ahead
          text
        elsif modules.include?('images') && has_image
          image
        elsif modules.include?('links') && has_link_ahead
          link
        elsif modules.include?('code') && has_code_ahead
          code
        elsif em_has_strong_within_em
          strong_within_em
        else
          case get_next_token_kind
            when TokenManager::ASTERISK
              @tree.add_single_value(Ast::Text.new, consume_token(TokenManager::ASTERISK))
            when TokenManager::BACKTICK
              @tree.add_single_value(Ast::Text.new, consume_token(TokenManager::BACKTICK))
            when TokenManager::LBRACK
              @tree.add_single_value(Ast::Text.new, consume_token(TokenManager::LBRACK))
            else
              break
          end
        end
      end
      consume_token(TokenManager::UNDERSCORE)
      @tree.close_scope(em)
    end

    def code
      code = Ast::Code.new
      @tree.open_scope
      consume_token(TokenManager::BACKTICK)
      code_text
      consume_token(TokenManager::BACKTICK)
      @tree.close_scope(code)
    end

    def code_text
      text = Ast::Text.new
      @tree.open_scope
      s = StringIO.new('')
      loop do
        case get_next_token_kind
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
            unless next_after_space(TokenManager::EOL, TokenManager::EOF)
              case get_next_token_kind
                when TokenManager::SPACE
                  s << consume_token(TokenManager::SPACE).image
                when TokenManager::TAB
                  consume_token(TokenManager::TAB)
                  s << '    '
              end
            end
        end

        break unless code_text_has_any_token_ahead
      end
      text.value = s.string
      @tree.close_scope(text)
    end

    def loose_char
      text = Ast::Text.new
      @tree.open_scope
      case get_next_token_kind
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

    def line_break
      linebreak = Ast::LineBreak.new
      @tree.open_scope
      while get_next_token_kind == TokenManager::SPACE || get_next_token_kind == TokenManager::TAB
        consume_token(get_next_token_kind)
      end
      token = consume_token(TokenManager::EOL)
      linebreak.explicit = token.image.start_with?("  ");
      @tree.close_scope(linebreak)
    end

    def level_white_space(threshold)
      current_pos = 1
      while get_next_token_kind == TokenManager::GT
        consume_token(get_next_token_kind)
      end
      while (get_next_token_kind == TokenManager::SPACE || get_next_token_kind == TokenManager::TAB) && current_pos < (threshold - 1)
        current_pos = consume_token(get_next_token_kind).begin_column
      end
    end

    def code_language
      s = StringIO.new('')
      loop do
        case get_next_token_kind
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
            s << '    '
        end
        break if get_next_token_kind == TokenManager::EOL || get_next_token_kind == TokenManager::EOF
      end
      s.string
    end

    def inline
      loop do
        if has_inline_text_ahead
          text
        elsif @modules.include?('images') && has_image_ahead
          image
        elsif @modules.include?('links') && has_link_ahead
          link
        elsif @modules.include?('formatting') && multiline_ahead(TokenManager::ASTERISK)
          strong_multiline
        elsif @modules.include?('formatting') && multiline_ahead(TokenManager::UNDERSCORE)
          em_multiline
        elsif @modules.include?('code') && multiline_ahead(TokenManager::BACKTICK)
          code_multiline
        else
          loose_char
        end
        break unless has_inline_element_ahead
      end
    end

    def resource_text
      text = Ast::Text.new
      @tree.open_scope
      s = StringIO.new('')
      loop do
        case get_next_token_kind
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
            unless next_after_space(TokenManager::RBRACK)
              case get_next_token_kind
                when TokenManager::SPACE
                  s << consume_token(TokenManager::SPACE).image
                when TokenManager::TAB
                  consume_token(TokenManager::TAB)
                  s << '    '
              end
            end
        end
        break unless resource_has_element_ahead
      end
      text.value = s.string
      @tree.close_scope(text)
    end

    def resource_url
      consume_token(TokenManager::LPAREN)
      white_space
      ref = resource_url_text
      white_space
      consume_token(TokenManager::RPAREN)
      ref
    end

    def resource_url_text
      s = StringIO.new('')
      while resource_text_has_elements_ahead
        case get_next_token_kind
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
            s << consume_token(TokenManager::ESCAPED_CHAR).image[1..-1]
          when TokenManager::IMAGE_LABEL
            s << consume_token(TokenManager::IMAGE_LABEL).image
          when TokenManager::GT
            s << consume_token(TokenManager::GT).image
          when TokenManager::LBRACK
            s << consume_token(TokenManager::LBRACK).image
          when TokenManager::LPAREN
            s << consume_token(TokenManager::LPAREN).image
          when TokenManager::LT
            s << consume_token(TokenManager::LT).image
          when TokenManager::RBRACK
            s << consume_token(TokenManager::RBRACK).image
          when TokenManager::UNDERSCORE
            s << consume_token(TokenManager::UNDERSCORE).image
          else
            unless next_after_space(TokenManager::RPAREN)
              case get_next_token_kind
                when TokenManager::SPACE
                  s << (consume_token(TokenManager::SPACE).image)
                when TokenManager::TAB
                  consume_token(TokenManager::TAB)
                  s << '    '
              end
            end
        end
      end
      s.string
    end

    def strong_multiline
      strong = Ast::Strong.new
      @tree.open_scope
      consume_token(TokenManager::ASTERISK)
      strong_multiline_content
      while text_ahead
        line_break
        white_space
        strong_multiline_content
      end
      consume_token(TokenManager::ASTERISK)
      @tree.close_scope(strong)
    end

    def strong_multiline_content
      loop do
        if has_text_ahead
          text
        elsif modules.include?('images') && has_image_ahead
          image
        elsif modules.include?('links') && has_link_ahead
          link
        elsif modules.include?('code') && has_code_ahead
          code
        elsif has_em_within_strong_multiline
          em_within_strong_multiline
        else
          case get_next_token_kind
            when TokenManager::BACKTICK
              @tree.add_single_value(Ast::Text.new, consume_token(TokenManager::BACKTICK))
            when TokenManager::LBRACK
              @tree.add_single_value(Ast::Text.new, consume_token(TokenManager::LBRACK))
            when TokenManager::UNDERSCORE
              @tree.add_single_value(Ast::Text.new, consume_token(TokenManager::UNDERSCORE))
          end
        end
        break unless strong_multiline_has_elements_ahead
      end
    end

    def strong_within_em_multiline
      strong = Ast::Strong.new
      @tree.open_scope
      consume_token(TokenManager::ASTERISK)
      strong_within_em_multiline_content
      while text_ahead
        line_break
        strong_within_em_multiline_content
      end
      consume_token(TokenManager::ASTERISK)
      @tree.close_scope(strong)
    end

    def strong_within_em_multiline_content
      loop do
        if has_text_ahead
          text
        elsif modules.include?('images') && has_image_ahead
          image
        elsif modules.include?('links') && has_link_ahead
          link
        elsif modules.include?('code') && has_code_ahead
          code
        else
          case get_next_token_kind
            when TokenManager::BACKTICK
              @tree.add_single_value(Ast::Text.new, consume_token(TokenManager::BACKTICK))
            when TokenManager::LBRACK
              @tree.add_single_value(Ast::Text.new, consume_token(TokenManager::LBRACK))
            when TokenManager::UNDERSCORE
              @tree.add_single_value(Ast::Text.new, consume_token(TokenManager::UNDERSCORE))
          end
        end
        break unless strong_within_em_multiline_has_elements_ahead
      end
    end

    def strong_within_em
      strong = Ast::Strong.new
      @tree.open_scope
      consume_token(TokenManager::ASTERISK)
      loop do
        if has_text_ahead
          text
        elsif modules.include?('images') && has_image_ahead
          image
        elsif modules.include?('links') && has_link_ahead
          link
        elsif modules.include?('code') && has_code_ahead
          code
        else
          case get_next_token_kind
            when TokenManager::BACKTICK
              @tree.add_single_value(Ast::Text.new, consume_token(TokenManager::BACKTICK))
            when TokenManager::LBRACK
              @tree.add_single_value(Ast::Text.new, consume_token(TokenManager::LBRACK))
            when TokenManager::UNDERSCORE
              @tree.add_single_value(Ast::Text.new, consume_token(TokenManager::UNDERSCORE))
          end
        end
        break unless strong_within_em_has_elements_ahead
      end
      consume_token(TokenManager::ASTERISK)
      @tree.close_scope(strong)
    end

    def em_multiline
      em = Ast::Em.new
      @tree.open_scope
      consume_token(TokenManager::UNDERSCORE)
      em_multiline_content
      while text_ahead
        line_break
        white_space
        em_multiline_content
      end
      consume_token(TokenManager::UNDERSCORE)
      @tree.close_scope(em)
    end

    def em_multiline_content
      loop do
        if has_text_ahead
          text
        elsif modules.include?('images') && has_image_ahead
          image
        elsif modules.include?('links') && has_link_ahead
          link
        elsif modules.include?('code') && multiline_ahead(TokenManager::BACKTICK)
          code_multiline
        elsif has_strong_within_em_multiline_ahead
          strong_within_em_multiline
        else
          case get_next_token_kind
            when TokenManager::ASTERISK
              @tree.add_single_value(Ast::Text.new, consume_token(TokenManager::ASTERISK))
            when TokenManager::BACKTICK
              @tree.add_single_value(Ast::Text.new, consume_token(TokenManager::BACKTICK))
            when TokenManager::LBRACK
              @tree.add_single_value(Ast::Text.new, consume_token(TokenManager::LBRACK))
          end
        end
        break unless em_multiline_content_has_elements_ahead
      end
    end

    def em_within_strong_multiline
      em = Ast::Em.new
      @tree.open_scope
      consume_token(TokenManager::UNDERSCORE)
      em_within_strong_multiline_content
      while text_ahead
        line_break
        em_within_strong_multiline_content
      end
      consume_token(TokenManager::UNDERSCORE)
      @tree.close_scope(em)
    end

    def em_within_strong_multiline_content
      loop do
        if has_text_ahead
          text
        elsif modules.include?('images') && has_image_ahead
          image
        elsif modules.include?('links') && has_link_ahead
          link
        elsif modules.include?('code') && has_code_ahead
          code
        else
          case get_next_token_kind
            when TokenManager::ASTERISK
              @tree.add_single_value(Ast::Text.new, consume_token(TokenManager::ASTERISK))
            when TokenManager::BACKTICK
              @tree.add_single_value(Ast::Text.new, consume_token(TokenManager::BACKTICK))
            when TokenManager::LBRACK
              @tree.add_single_value(Ast::Text.new, consume_token(TokenManager::LBRACK))
          end
        end
        break if !em_within_strong_multiline_content_has_elements_ahead
      end
    end

    def em_within_strong
      em = Ast::Em.new
      @tree.open_scope
      consume_token(TokenManager::UNDERSCORE)
      loop do
        if has_text_ahead
          text
        elsif modules.include?('images') && has_image_ahead
          image
        elsif modules.include?('links') && has_link_ahead
          link
        elsif modules.include?('code') && has_code_ahead
          code
        else
          case get_next_token_kind
            when TokenManager::ASTERISK
              @tree.add_single_value(Ast::Text.new, consume_token(TokenManager::ASTERISK))
            when TokenManager::BACKTICK
              @tree.add_single_value(Ast::Text.new, consume_token(TokenManager::BACKTICK))
            when TokenManager::LBRACK
              @tree.add_single_value(Ast::Text.new, consume_token(TokenManager::LBRACK))
          end
        end
        break unless em_within_strong_has_elements_ahead
      end
      consume_token(TokenManager::UNDERSCORE)
      @tree.close_scope(em)
    end

    def code_multiline
      code = Ast::Code.new
      @tree.open_scope
      consume_token(TokenManager::BACKTICK)
      code_text
      while text_ahead
        line_break
        white_space
        while get_next_token_kind == TokenManager::GT
          consume_token(TokenManager::GT)
          white_space
        end
        code_text
      end
      consume_token(TokenManager::BACKTICK)
      @tree.close_scope(code)
    end

    def white_space
      while get_next_token_kind == TokenManager::SPACE || get_next_token_kind == TokenManager::TAB
        consume_token(get_next_token_kind)
      end
    end

    def has_any_block_elements_ahead
      begin
        @look_ahead = 1
        @last_position = @scan_position = @token
        return !scan_more_block_elements
      rescue LookaheadSuccess
        return true
      end
    end

    def block_ahead(block_begin_column)
      if get_next_token_kind == TokenManager::EOL
        i = 2
        t = nil
        loop do
          quote_level = 0
          loop do
            t = get_token(i)
            i+=1
            if t.kind == TokenManager::GT
              if t.begin_column == 1 && @current_block_level > 0 && @current_quote_level == 0
                return false
              end
              quote_level+=1
            end
            break if t.kind != TokenManager::GT && t.kind != TokenManager::SPACE && t.kind != TokenManager::TAB
          end
          return true if quote_level > @current_quote_level
          return false if quote_level < @current_quote_level
          break if t.kind != TokenManager::EOL
        end
        return t.kind != TokenManager::EOF && (@current_block_level == 0 || t.begin_column >= (block_begin_column + 2))
      end
      false
    end

    def multiline_ahead(token)
      if get_next_token_kind == token && get_token(2).kind != token && get_token(2).kind != TokenManager::EOL
        i=2
        loop do
          t = get_token(i)
          if t.kind == token
            return true
          elsif t.kind == TokenManager::EOL
            i = skip(i + 1, TokenManager::SPACE, TokenManager::TAB)
            quote_level = new_quote_level(i)
            if quote_level == @current_quote_level
              i = skip(i, TokenManager::SPACE, TokenManager::TAB, TokenManager::GT)
              if get_token(i).kind == token || get_token(i).kind == TokenManager::EOL || get_token(i).kind == TokenManager::DASH \
            || (get_token(i).kind == TokenManager::DIGITS && get_token(i + 1).kind == TokenManager::DOT) \
            || (get_token(i).kind == TokenManager::BACKTICK && get_token(i + 1).kind == TokenManager::BACKTICK && get_token(i + 2).kind == TokenManager::BACKTICK) \
            || heading_ahead(i)
                return false
              end
            else
              return false
            end
          elsif t.kind == TokenManager::EOF
            return false
          end
          i += 1
        end
      end
      false
    end

    def fences_ahead
      i = skip(2, TokenManager::SPACE, TokenManager::TAB, TokenManager::GT)
      if get_token(i).kind == TokenManager::BACKTICK && get_token(i + 1).kind == TokenManager::BACKTICK && get_token(i + 2).kind == TokenManager::BACKTICK
        i = skip(i + 3, TokenManager::SPACE, TokenManager::TAB)
        return get_token(i).kind == TokenManager::EOL || get_token(i).kind == TokenManager::EOF
      end
      false
    end

    def heading_ahead(offset)
      if get_token(offset).kind == TokenManager::EQ
        heading = 1

        i = offset + 1
        loop do
          if get_token(i).kind != TokenManager::EQ
            return true
          end
          if (heading+=1) > 6
            return false
          end
          i+= 1
        end
      end
      false
    end

    def list_item_ahead(list_begin_column, ordered)
      if get_next_token_kind == TokenManager::EOL
        i = 2
        eol = 1
        loop do
          t = get_token(i)
          if t.kind == TokenManager::EOL && (eol+=1) > 2
            return false
          elsif t.kind != TokenManager::SPACE && t.kind != TokenManager::TAB && t.kind != TokenManager::GT && t.kind != TokenManager::EOL
            if ordered
              return t.kind == TokenManager::DIGITS && get_token(i + 1).kind == TokenManager::DOT && t.begin_column >= list_begin_column
            end
            return t.kind == TokenManager::DASH && t.begin_column >= list_begin_column
          end
          i+=1
        end
      end
      false
    end

    def text_ahead
      if get_next_token_kind == TokenManager::EOL && get_token(2).kind != TokenManager::EOL
        i = skip(2, TokenManager::SPACE, TokenManager::TAB)
        quote_level = new_quote_level(i)
        if (quote_level == @current_quote_level || !@modules.include?('blockquotes'))
          i = skip(i, TokenManager::SPACE, TokenManager::TAB, TokenManager::GT)

          t = get_token(i)
          return get_token(i).kind != TokenManager::EOL && !(@modules.include?('lists') && t.kind == TokenManager::DASH) \
          && !(@modules.include?('lists') && t.kind == TokenManager::DIGITS && get_token(i + 1).kind == TokenManager::DOT) \
          && !(get_token(i).kind == TokenManager::BACKTICK && get_token(i + 1).kind == TokenManager::BACKTICK && get_token(i + 2).kind == TokenManager::BACKTICK) \
          && !(@modules.include?('headings') && heading_ahead(i))
        end
      end
      false
    end

    def next_after_space(*tokens)
      i = skip(1, TokenManager::SPACE, TokenManager::TAB)
      tokens.include?(get_token(i).kind)
    end

    def new_quote_level(offset)
      quote_level = 0
      i = offset
      loop do
        t = get_token(i)
        if t.kind == TokenManager::GT
          quote_level+=1
        elsif t.kind != TokenManager::SPACE && t.kind != TokenManager::TAB
          return quote_level
        end
        i+=1
      end
    end

    def skip(offset, *tokens)
      i = offset
      loop do
        t = get_token(i)
        unless tokens.include?(t.kind)
          return i
        end
        i+=1
      end
    end

    def has_ordered_list_ahead
      @look_ahead = 2
      @last_position = @scan_position = @token
      begin
        return !scan_token(TokenManager::DIGITS) && !scan_token(TokenManager::DOT)
      rescue LookaheadSuccess
        return true
      end
    end

    def has_fenced_code_block_ahead
      @look_ahead = 3
      @last_position = @scan_position = @token
      begin
        return !scan_fenced_code_block
      rescue LookaheadSuccess
        return true
      end
    end

    def heading_has_inline_elements_ahead
      @look_ahead = 1
      @last_position = @scan_position = @token
      begin
        xsp = @scan_position
        if scan_text_tokens
          @scan_position = xsp
          if scan_image
            @scan_position = xsp
            if scan_link
              @scan_position = xsp
              if scan_strong
                @scan_position = xsp
                if scan_em
                  @scan_position = xsp
                  if scan_code
                    @scan_position = xsp
                    return false if scan_loose_char
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

    def has_text_ahead
      @look_ahead = 1
      @last_position = @scan_position = @token
      begin
        return !scan_text_tokens
      end
    rescue LookaheadSuccess
      return true
    end

    def has_image_ahead
      @look_ahead = 2147483647
      @last_position = @scan_position = @token
      begin
        return !scan_image
      rescue LookaheadSuccess
        return true
      end
    end

    def block_quote_has_empty_line_ahead
      @look_ahead = 2147483647
      @last_position = @scan_position = @token
      begin
        return !scan_block_quote_empty_line
      rescue LookaheadSuccess
        return true
      end
    end

    def has_strong_ahead
      @look_ahead = 2147483647
      @last_position = @scan_position = @token
      begin
        return !scan_strong
      rescue LookaheadSuccess
        return true
      end
    end

    def has_em_ahead
      @look_ahead = 2147483647
      @last_position = @scan_position = @token
      begin
        return !scan_em
      rescue LookaheadSuccess
        return true
      end
    end

    def has_code_ahead
      @look_ahead = 2147483647
      @last_position = @scan_position = @token
      begin
        return !scan_code
      rescue LookaheadSuccess
        return true
      end
    end

    def block_quote_has_any_block_elements_ahead
      @look_ahead = 1
      @last_position = @scan_position = @token
      begin
        return !scan_more_block_elements
      rescue LookaheadSuccess
        return true
      end
    end

    def has_block_quote_empty_lines_ahead
      @look_ahead = 2147483647
      @last_position = @scan_position = @token
      begin
        return !scan_block_quote_empty_lines
      rescue LookaheadSuccess
        return true
      end
    end

    def list_item_has_inline_elements
      @look_ahead = 1
      @last_position = @scan_position = @token
      begin
        return !scan_more_block_elements
      rescue LookaheadSuccess
        return true
      end
    end

    def has_inline_text_ahead
      @look_ahead = 1
      @last_position = @scan_position = @token

      begin
        return !scan_text_tokens
      rescue LookaheadSuccess
        return true
      end
    end

    def has_inline_element_ahead
      @look_ahead = 1
      @last_position = @scan_position = @token
      begin
        return !scan_inline_element
      rescue LookaheadSuccess
        return true
      end
    end

    def image_has_any_elements
      @look_ahead = 1
      @last_position = @scan_position = @token
      begin
        return !scan_image_element
      rescue LookaheadSuccess
        return true
      end
    end

    def has_resource_text_ahead
      @look_ahead = 1
      @last_position = @scan_position = @token
      begin
        return !scan_resource_elements
      rescue LookaheadSuccess
        return true
      end
    end

    def link_has_any_elements
      @look_ahead = 1
      @last_position = @scan_position = @token
      begin
        return !scan_link_element
      rescue LookaheadSuccess
        return true
      end
    end

    def has_resource_url_ahead
      @look_ahead = 2147483647
      @last_position = @scan_position = @token
      begin
        return !scan_resource_url
      rescue LookaheadSuccess
        return true
      end
    end

    def resource_has_element_ahead
      @look_ahead = 2
      @last_position = @scan_position = @token
      begin
        return !scan_resource_element
      rescue LookaheadSuccess
        return true
      end
    end

    def resource_text_has_elements_ahead
      @look_ahead = 1
      @last_position = @scan_position = @token
      begin
        return !scan_resource_text_element
      rescue LookaheadSuccess
        return true
      end
    end

    def has_em_within_strong_multiline
      @look_ahead = 2147483647
      @last_position = @scan_position = @token
      begin
        return !scan_em_within_strong_multiline
      rescue LookaheadSuccess
        return true
      end
    end

    def strong_multiline_has_elements_ahead
      @look_ahead = 1
      @last_position = @scan_position = @token
      begin
        return !scan_strong_multiline_elements
      rescue LookaheadSuccess
        return true
      end
    end

    def strong_within_em_multiline_has_elements_ahead
      @look_ahead = 1
      @last_position = @scan_position = @token
      begin
        return !scan_strong_within_em_multiline_elements
      rescue LookaheadSuccess
        return true
      end
    end

    def has_image
      @look_ahead = 2147483647
      @last_position = @scan_position = @token
      begin
        return !scan_image
      rescue LookaheadSuccess
        return true
      end
    end

    def has_link_ahead
      @look_ahead = 2147483647
      @last_position = @scan_position = @token
      begin
        return !scan_link
      rescue LookaheadSuccess
        return true
      end
    end

    def strong_em_within_strong_ahead
      @look_ahead = 2147483647
      @last_position = @scan_position = @token
      begin
        return !scan_em_within_strong
      rescue LookaheadSuccess
        return true
      end
    end

    def strong_has_elements
      @look_ahead = 1
      @last_position = @scan_position = @token
      begin
        return !scan_strong_elements
      rescue LookaheadSuccess
        return true
      end
    end

    def strong_within_em_has_elements_ahead
      @look_ahead = 1
      @last_position = @scan_position = @token
      begin
        return !scan_strong_within_em_elements
      rescue LookaheadSuccess
        return true
      end
    end

    def has_strong_within_em_multiline_ahead
      @look_ahead = 2147483647
      @last_position = @scan_position = @token
      begin
        return !scan_strong_within_em_multiline
      rescue LookaheadSuccess
        return true
      end
    end

    def em_multiline_content_has_elements_ahead
      @look_ahead = 1
      @last_position = @scan_position = @token
      begin
        return !scan_em_multiline_content_elements
      rescue LookaheadSuccess
        return true
      end
    end

    def em_within_strong_multiline_content_has_elements_ahead
      @look_ahead = 1
      @last_position = @scan_position = @token
      begin
        return !scan_em_within_strong_multiline_content
      rescue LookaheadSuccess
        return true
      end
    end

    def em_has_strong_within_em
      @look_ahead = 2147483647
      @last_position = @scan_position = @token
      begin
        return !scan_strong_within_em
      rescue LookaheadSuccess
        return true
      end
    end

    def em_has_elements
      @look_ahead = 1
      @last_position = @scan_position = @token
      begin
        return !scan_em_elements
      rescue LookaheadSuccess
        return true
      end
    end

    def em_within_strong_has_elements_ahead
      @look_ahead = 1
      @last_position = @scan_position = @token
      begin
        return !scan_em_within_strong_elements
      rescue LookaheadSuccess
        return true
      end
    end

    def code_text_has_any_token_ahead
      @look_ahead = 1
      @last_position = @scan_position = @token
      begin
        return !scan_code_text_tokens
      rescue LookaheadSuccess
        return true
      end
    end

    def text_has_tokens_ahead
      @look_ahead = 1
      @last_position = @scan_position = @token
      begin
        return !scan_text
      rescue LookaheadSuccess
        return true
      end
    end

    def scan_loose_char
      xsp = @scan_position
      if scan_token(TokenManager::ASTERISK)
        @scan_position = xsp
        if scan_token(TokenManager::BACKTICK)
          @scan_position = xsp
          if scan_token(TokenManager::LBRACK)
            @scan_position = xsp
            return scan_token(TokenManager::UNDERSCORE)
          end
        end
      end
      false
    end

    def scan_text
      xsp = @scan_position
      if scan_token(TokenManager::BACKSLASH)
        @scan_position = xsp
        if scan_token(TokenManager::CHAR_SEQUENCE)
          @scan_position = xsp
          if scan_token(TokenManager::COLON)
            @scan_position = xsp
            if scan_token(TokenManager::DASH)
              @scan_position = xsp
              if scan_token(TokenManager::DIGITS)
                @scan_position = xsp
                if scan_token(TokenManager::DOT)
                  @scan_position = xsp
                  if scan_token(TokenManager::EQ)
                    @scan_position = xsp
                    if scan_token(TokenManager::ESCAPED_CHAR)
                      @scan_position = xsp
                      if scan_token(TokenManager::GT)
                        @scan_position = xsp
                        if scan_token(TokenManager::IMAGE_LABEL)
                          @scan_position = xsp
                          if scan_token(TokenManager::LPAREN)
                            @scan_position = xsp
                            if scan_token(TokenManager::LT)
                              @scan_position = xsp
                              if scan_token(TokenManager::RBRACK)
                                @scan_position = xsp
                                if scan_token(TokenManager::RPAREN)
                                  @scan_position = xsp
                                  @looking_ahead = true
                                  @semantic_look_ahead = !next_after_space(TokenManager::EOL, TokenManager::EOF)
                                  @looking_ahead = false
                                  return (!@semantic_look_ahead || scan_whitespace_token)
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
      false
    end

    def scan_text_tokens
      return true if scan_text
      while true
        xsp = @scan_position
        if scan_text
          @scan_position = xsp
          break
        end
      end
      false
    end

    def scan_code_text_tokens
      xsp = @scan_position
      if scan_token(TokenManager::ASTERISK)
        @scan_position = xsp
        if scan_token(TokenManager::BACKSLASH)
          @scan_position = xsp
          if scan_token(TokenManager::CHAR_SEQUENCE)
            @scan_position = xsp
            if scan_token(TokenManager::COLON)
              @scan_position = xsp
              if scan_token(TokenManager::DASH)
                @scan_position = xsp
                if scan_token(TokenManager::DIGITS)
                  @scan_position = xsp
                  if scan_token(TokenManager::DOT)
                    @scan_position = xsp
                    if scan_token(TokenManager::EQ)
                      @scan_position = xsp
                      if scan_token(TokenManager::ESCAPED_CHAR)
                        @scan_position = xsp
                        if scan_token(TokenManager::IMAGE_LABEL)
                          @scan_position = xsp
                          if scan_token(TokenManager::LT)
                            @scan_position = xsp
                            if scan_token(TokenManager::LBRACK)
                              @scan_position = xsp
                              if scan_token(TokenManager::RBRACK)
                                @scan_position = xsp
                                if scan_token(TokenManager::LPAREN)
                                  @scan_position = xsp
                                  if scan_token(TokenManager::GT)
                                    @scan_position = xsp
                                    if scan_token(TokenManager::RPAREN)
                                      @scan_position = xsp
                                      if scan_token(TokenManager::UNDERSCORE)
                                        @scan_position = xsp
                                        @looking_ahead = true
                                        @semantic_look_ahead = !next_after_space(TokenManager::EOL, TokenManager::EOF)
                                        @looking_ahead = false
                                        return (!@semantic_look_ahead || scan_whitespace_token)
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
      false
    end

    def scan_code
      scan_token(TokenManager::BACKTICK) || scan_code_text_tokens_ahead() || scan_token(TokenManager::BACKTICK)
    end

    def scan_code_multiline
      if scan_token(TokenManager::BACKTICK) || scan_code_text_tokens_ahead
        return true
      end
      while true
        xsp = @scan_position
        if has_code_text_on_next_line_ahead
          @scan_position = xsp
          break
        end
      end
      scan_token(TokenManager::BACKTICK)
    end

    def scan_code_text_tokens_ahead
      return true if scan_code_text_tokens
      while true
        xsp = @scan_position
        if scan_code_text_tokens
          @scan_position = xsp
          break
        end
      end
      false
    end

    def has_code_text_on_next_line_ahead
      return true if scan_whitespace_token_before_eol
      while true
        xsp = @scan_position
        if scan_token(TokenManager::GT)
          @scan_position = xsp
          break
        end
      end
      scan_code_text_tokens_ahead
    end

    def scan_whitespace_tokens
      while true
        xsp = @scan_position
        if scan_whitespace_token
          @scan_position = xsp
          break
        end
      end
      false
    end

    def scan_whitespace_token_before_eol
      return scan_whitespace_tokens || scan_token(TokenManager::EOL)
    end

    def scan_em_within_strong_elements
      xsp = @scan_position
      if scan_text_tokens
        @scan_position = xsp
        if scan_image
          @scan_position = xsp
          if scan_link
            @scan_position = xsp
            if scan_code
              @scan_position = xsp
              if scan_token(TokenManager::ASTERISK)
                @scan_position = xsp
                if scan_token(TokenManager::BACKTICK)
                  @scan_position = xsp
                  return scan_token(TokenManager::LBRACK)
                end
              end
            end
          end
        end
      end
      false
    end

    def scan_em_within_strong
      return true if scan_token(TokenManager::UNDERSCORE) || scan_em_within_strong_elements
      while true
        xsp = @scan_position
        if scan_em_within_strong_elements
          @scan_position = xsp
          break
        end
      end
      scan_token(TokenManager::UNDERSCORE)
    end

    def scan_em_elements
      xsp = @scan_position
      if scan_text_tokens
        @scan_position = xsp
        if scan_image
          @scan_position = xsp
          if scan_link
            @scan_position = xsp
            if scan_code
              @scan_position = xsp
              if scan_strong_within_em
                @scan_position = xsp
                if scan_token(TokenManager::ASTERISK)
                  @scan_position = xsp
                  if scan_token(TokenManager::BACKTICK)
                    @scan_position = xsp
                    return scan_token(TokenManager::LBRACK)
                  end
                end
              end
            end
          end
        end
      end
      false
    end

    def scan_em
      return true if scan_token(TokenManager::UNDERSCORE) || scan_em_elements
      while true
        xsp = @scan_position
        if scan_em_elements
          @scan_position = xsp
          break
        end
      end
      scan_token(TokenManager::UNDERSCORE)
    end

    def scan_em_within_strong_multiline_content
      xsp = @scan_position
      if scan_text_tokens
        @scan_position = xsp
        if scan_image
          @scan_position = xsp
          if scan_link
            @scan_position = xsp
            if scan_code
              @scan_position = xsp
              if scan_token(TokenManager::ASTERISK)
                @scan_position = xsp
                if scan_token(TokenManager::BACKTICK)
                  @scan_position = xsp
                  return scan_token(TokenManager::LBRACK)
                end
              end
            end
          end
        end
      end
      false
    end

    def has_no_em_within_strong_multiline_content_ahead
      if scan_em_within_strong_multiline_content
        return true
      end
      while true
        xsp = @scan_position
        if scan_em_within_strong_multiline_content
          @scan_position = xsp
          break
        end
      end
      false
    end

    def scan_em_within_strong_multiline
      if scan_token(TokenManager::UNDERSCORE) || has_no_em_within_strong_multiline_content_ahead
        return true
      end
      while true
        xsp = @scan_position
        if scan_whitespace_token_before_eol || has_no_em_within_strong_multiline_content_ahead
          @scan_position = xsp
          break
        end
      end
      scan_token(TokenManager::UNDERSCORE)
    end

    def scan_em_multiline_content_elements
      xsp = @scan_position
      if scan_text_tokens
        @scan_position = xsp
        if scan_image
          @scan_position = xsp
          if scan_link
            @scan_position = xsp
            @looking_ahead = true
            @semantic_look_ahead = multiline_ahead(TokenManager::BACKTICK)
            @looking_ahead = false
            if !@semantic_look_ahead || scan_code_multiline
              @scan_position = xsp
              if scan_strong_within_em_multiline
                @scan_position = xsp
                if scan_token(TokenManager::ASTERISK)
                  @scan_position = xsp
                  if scan_token(TokenManager::BACKTICK)
                    @scan_position = xsp
                    return scan_token(TokenManager::LBRACK)
                  end
                end
              end
            end
          end
        end
      end
      false
    end

    def scan_strong_within_em_elements
      xsp = @scan_position
      if scan_text_tokens
        @scan_position = xsp
        if scan_image
          @scan_position = xsp
          if scan_link
            @scan_position = xsp
            if scan_code
              @scan_position = xsp
              if scan_token(TokenManager::BACKTICK)
                @scan_position = xsp
                if scan_token(TokenManager::LBRACK)
                  @scan_position = xsp
                  return scan_token(TokenManager::UNDERSCORE)
                end
              end
            end
          end
        end
      end
      false
    end

    def scan_strong_within_em
      return true if scan_token(TokenManager::ASTERISK) || scan_strong_within_em_elements
      while true
        xsp = @scan_position
        if scan_strong_within_em_elements
          @scan_position = xsp
          break
        end
      end
      scan_token(TokenManager::ASTERISK)
    end

    def scan_strong_elements
      xsp = @scan_position
      if scan_text_tokens
        @scan_position = xsp
        if scan_image
          @scan_position = xsp
          if scan_link
            @scan_position = xsp
            @looking_ahead = true
            @semantic_look_ahead = multiline_ahead(TokenManager::BACKTICK)
            @looking_ahead = false
            if !@semantic_look_ahead || scan_code_multiline
              @scan_position = xsp
              if scan_em_within_strong
                @scan_position = xsp
                if scan_token(TokenManager::BACKTICK)
                  @scan_position = xsp
                  if scan_token(TokenManager::LBRACK)
                    @scan_position = xsp
                    return scan_token(TokenManager::UNDERSCORE)
                  end
                end
              end
            end
          end
        end
      end
      false
    end

    def scan_strong
      return true if scan_token(TokenManager::ASTERISK) || scan_strong_elements
      while true
        xsp = @scan_position
        if scan_strong_elements
          @scan_position = xsp
          break
        end
      end
      scan_token(TokenManager::ASTERISK)
    end

    def scan_strong_within_em_multiline_elements
      xsp = @scan_position
      if scan_text_tokens
        @scan_position = xsp
        if scan_image
          @scan_position = xsp
          if scan_link
            @scan_position = xsp
            if scan_code
              @scan_position = xsp
              if scan_token(TokenManager::BACKTICK)
                @scan_position = xsp
                if scan_token(TokenManager::LBRACK)
                  @scan_position = xsp
                  return scan_token(TokenManager::UNDERSCORE)
                end
              end
            end
          end
        end
      end
      false
    end

    def scan_for_more_strong_within_em_multiline_elements
      return true if scan_strong_within_em_multiline_elements
      loop do
        xsp = @scan_position
        if scan_strong_within_em_multiline_elements
          @scan_position = xsp
          break
        end
      end
      false
    end

    def scan_strong_within_em_multiline
      return true if scan_token(TokenManager::ASTERISK) || scan_for_more_strong_within_em_multiline_elements
      while true
        xsp = @scan_position
        if scan_whitespace_token_before_eol || scan_for_more_strong_within_em_multiline_elements
          @scan_position = xsp
          break
        end
      end
      scan_token(TokenManager::ASTERISK)
    end

    def scan_strong_multiline_elements
      xsp = @scan_position
      if scan_text_tokens
        @scan_position = xsp
        if scan_image
          @scan_position = xsp
          if scan_link
            @scan_position = xsp
            if scan_code
              @scan_position = xsp
              if scan_em_within_strong_multiline
                @scan_position = xsp
                if scan_token(TokenManager::BACKTICK)
                  @scan_position = xsp
                  if scan_token(TokenManager::LBRACK)
                    @scan_position = xsp
                    return scan_token(TokenManager::UNDERSCORE)
                  end
                end
              end
            end
          end
        end
      end
      false
    end

    def scan_resource_text_element
      xsp = @scan_position
      if scan_token(TokenManager::ASTERISK)
        @scan_position = xsp
        if scan_token(TokenManager::BACKSLASH)
          @scan_position = xsp
          if scan_token(TokenManager::BACKTICK)
            @scan_position = xsp
            if scan_token(TokenManager::CHAR_SEQUENCE)
              @scan_position = xsp
              if scan_token(TokenManager::COLON)
                @scan_position = xsp
                if scan_token(TokenManager::DASH)
                  @scan_position = xsp
                  if scan_token(TokenManager::DIGITS)
                    @scan_position = xsp
                    if scan_token(TokenManager::DOT)
                      @scan_position = xsp
                      if scan_token(TokenManager::EQ)
                        @scan_position = xsp
                        if scan_token(TokenManager::ESCAPED_CHAR)
                          @scan_position = xsp
                          if scan_token(TokenManager::IMAGE_LABEL)
                            @scan_position = xsp
                            if scan_token(TokenManager::GT)
                              @scan_position = xsp
                              if scan_token(TokenManager::LBRACK)
                                @scan_position = xsp
                                if scan_token(TokenManager::LPAREN)
                                  @scan_position = xsp
                                  if scan_token(TokenManager::LT)
                                    @scan_position = xsp
                                    if scan_token(TokenManager::RBRACK)
                                      @scan_position = xsp
                                      if scan_token(TokenManager::UNDERSCORE)
                                        @scan_position = xsp
                                        @looking_ahead = true
                                        @semantic_look_ahead = !next_after_space(TokenManager::RPAREN)
                                        @looking_ahead = false
                                        return !@semantic_look_ahead || scan_whitespace_token
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
      false
    end

    def scan_image_element
      xsp = @scan_position
      if scan_resource_elements
        @scan_position = xsp
        return true if scan_loose_char
      end
      false
    end

    def scan_resource_text_elements
      while true
        xsp = @scan_position
        if scan_resource_text_element
          @scan_position = xsp
          break
        end
      end
      false
    end

    def scan_resource_url
      scan_token(TokenManager::LPAREN) || scan_whitespace_tokens || scan_resource_text_elements || scan_whitespace_tokens || scan_token(TokenManager::RPAREN)
    end

    def scan_link_element
      xsp = @scan_position
      if scan_image
        @scan_position = xsp
        if scan_strong
          @scan_position = xsp
          if scan_em
            @scan_position = xsp
            if scan_code
              @scan_position = xsp
              if scan_resource_elements
                @scan_position = xsp
                return scan_loose_char
              end
            end
          end
        end
      end
      false
    end

    def scan_resource_element
      xsp = @scan_position
      if scan_token(TokenManager::BACKSLASH)
        @scan_position = xsp
        if scan_token(TokenManager::COLON)
          @scan_position = xsp
          if scan_token(TokenManager::CHAR_SEQUENCE)
            @scan_position = xsp
            if scan_token(TokenManager::DASH)
              @scan_position = xsp
              if scan_token(TokenManager::DIGITS)
                @scan_position = xsp
                if scan_token(TokenManager::DOT)
                  @scan_position = xsp
                  if scan_token(TokenManager::EQ)
                    @scan_position = xsp
                    if scan_token(TokenManager::ESCAPED_CHAR)
                      @scan_position = xsp
                      if scan_token(TokenManager::IMAGE_LABEL)
                        @scan_position = xsp
                        if scan_token(TokenManager::GT)
                          @scan_position = xsp
                          if scan_token(TokenManager::LPAREN)
                            @scan_position = xsp
                            if scan_token(TokenManager::LT)
                              @scan_position = xsp
                              if scan_token(TokenManager::RPAREN)
                                @scan_position = xsp
                                @looking_ahead = true
                                @semantic_look_ahead = !next_after_space(TokenManager::RBRACK)
                                @looking_ahead = false
                                return !@semantic_look_ahead || scan_whitespace_token
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

    def scan_resource_elements
      return true if scan_resource_element
      loop do
        xsp = @scan_position
        if scan_resource_element
          @scan_position = xsp
          break
        end
      end
      false
    end

    def scan_link
      if scan_token(TokenManager::LBRACK) || scan_whitespace_tokens || scan_link_element
        return true
      end
      while true
        xsp = @scan_position
        if scan_link_element
          @scan_position = xsp
          break
        end
      end
      if scan_whitespace_tokens || scan_token(TokenManager::RBRACK)
        return true
      end
      xsp = @scan_position
      if scan_resource_url
        @scan_position = xsp
      end
      false
    end

    def scan_image
      if scan_token(TokenManager::LBRACK) || scan_whitespace_tokens || scan_token(TokenManager::IMAGE_LABEL) || scan_image_element
        return true
      end
      while true
        xsp = @scan_position
        if scan_image_element
          @scan_position = xsp
          break
        end
      end
      if scan_whitespace_tokens || scan_token(TokenManager::RBRACK)
        return true
      end
      xsp = @scan_position
      if scan_resource_url
        @scan_position = xsp
      end
      false
    end

    def scan_inline_element
      xsp = @scan_position
      if scan_text_tokens
        @scan_position = xsp
        if scan_image
          @scan_position = xsp
          if scan_link
            @scan_position = xsp
            @looking_ahead = true
            @semantic_look_ahead = multiline_ahead(TokenManager::ASTERISK)
            @looking_ahead = false
            if !@semantic_look_ahead || scan_token(TokenManager::ASTERISK)
              @scan_position = xsp
              @looking_ahead = true
              @semantic_look_ahead = multiline_ahead(TokenManager::UNDERSCORE)
              @looking_ahead = false
              if !@semantic_look_ahead || scan_token(TokenManager::UNDERSCORE)
                @scan_position = xsp
                @looking_ahead = true
                @semantic_look_ahead = multiline_ahead(TokenManager::BACKTICK)
                @looking_ahead = false
                if !@semantic_look_ahead || scan_code_multiline
                  @scan_position = xsp
                  return scan_loose_char
                end
              end
            end
          end
        end
      end
      false
    end

    def scan_paragraph
      if scan_inline_element
        return true
      end
      while true
        xsp = @scan_position
        if scan_inline_element
          @scan_position = xsp
          break
        end
      end
      false
    end

    def scan_whitespace_token
      xsp = @scan_position
      if scan_token(TokenManager::SPACE)
        @scan_position = xsp
        return true if scan_token(TokenManager::TAB)
      end
      false
    end

    def scan_fenced_code_block
      scan_token(TokenManager::BACKTICK) || scan_token(TokenManager::BACKTICK) || scan_token(TokenManager::BACKTICK)
    end

    def scan_block_quote_empty_lines
      scan_block_quote_empty_line || scan_token(TokenManager::EOL)
    end

    def scan_block_quote_empty_line
      return true if scan_token(TokenManager::EOL) || scan_whitespace_tokens || scan_token(TokenManager::GT) || scan_whitespace_tokens
      while true
        xsp = @scan_position
        if scan_token(TokenManager::GT) || scan_whitespace_tokens
          @scan_position = xsp
          break
        end
      end
      false
    end

    def scan_for_headersigns
      return true if scan_token(TokenManager::EQ)
      while true
        xsp = @scan_position
        if scan_token(TokenManager::EQ)
          @scan_position = xsp
          break
        end
      end
      false
    end

    def scan_more_block_elements
      xsp = @scan_position
      @looking_ahead = true
      @semantic_look_ahead = heading_ahead(1)
      @looking_ahead = false
      if !@semantic_look_ahead || scan_for_headersigns
        @scan_position = xsp
        if scan_token(TokenManager::GT)
          @scan_position = xsp
          if scan_token(TokenManager::DASH)
            @scan_position = xsp
            if scan_token(TokenManager::DIGITS) || scan_token(TokenManager::DOT)
              @scan_position = xsp
              if scan_fenced_code_block
                @scan_position = xsp
                return scan_paragraph
              end
            end
          end
        end
      end
      false
    end

    def scan_token(kind)
      if @scan_position == @last_position
        @look_ahead -= 1
        if @scan_position.next.nil?
          @last_position = @scan_position = @scan_position.next = @tm.get_next_token
        else
          @last_position = @scan_position = @scan_position.next
        end
      else
        @scan_position = @scan_position.next
      end
      if @scan_position.kind != kind
        return true
      end

      if (@look_ahead == 0) && (@scan_position == @last_position)
        raise @look_ahead_success
      end
      false
    end

    def get_next_token_kind
      if @next_token_kind != -1
        return @next_token_kind
      elsif (@next_token = @token.next).nil?
        @token.next = @tm.get_next_token
        return (@next_token_kind = @token.next.kind)
      end
      @next_token_kind = @next_token.kind
    end

    def consume_token(kind)
      old = @token

      if !@token.next.nil?
        @token = @token.next
      else
        @token = @token.next = @tm.get_next_token
      end

      @next_token_kind = -1
      return @token if @token.kind == kind
      @token = old
      @token
    end

    def get_token(index)
      t = @looking_ahead ? @scan_position : @token
      0.upto(index - 1) do
        if !t.next.nil?
          t = t.next
        else
          t = t.next = @tm.get_next_token
        end
      end
      t
    end

    def modules=(modules)
      @modules = modules
    end
  end
end