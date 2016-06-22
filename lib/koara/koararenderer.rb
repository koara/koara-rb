# encoding: utf-8
module Koara
  class KoaraRenderer

    def visit_document(node)
      @left = Array.new
      @out = StringIO.new
      node.children_accept(self)
    end

    def visit_heading(node)
      if !node.is_first_child
        indent
      end
      node.value.times {
        @out << '='
      }
      if node.has_children
        @out << ' '
        node.children_accept(self)
      end
      @out << "\n"
      if !node.is_last_child
        indent
        @out << "\n"
      end
    end

    def visit_blockquote(node)
      if !node.is_first_child
        indent
      end
      if node.has_children
        @out << '> '
        @left.push('> ')
        node.children_accept(self)
        @left.pop
      else
        @out << ">\n"
      end
      if !node.nested
        @out << "\n"
      end
    end

    def visit_list_block(node)
      node.children_accept(self)
      if !node.is_last_child
        indent
        @out << "\n"
        next_node = node.next
        if next_node.instance_of?(ListBlock) && next_node.ordered == node.ordered
          @out << "\n"
        end
      end
    end

    def visit_list_item(node)
      if !node.parent.nested || !node.is_first_child || !node.parent.is_first_child
        indent
      end
      @left.push('  ')
      if node.number
        @out << node.number + '.'
      else
        @out << '-'
      end
      if node.has_children
        @out << ' '
        node.children_accept(self)
      else
        @out << "\n"
      end
      @left.pop
    end

    def visit_codeblock(node)
      str = StringIO.new
      @left.each { |s| str << s }
      @out << '```'
      if node.language
        @out << node.language
      end
      @out << "\n"
      @out << node.value.gsub(/^/, str.string)
      @out << "\n"
      indent
      @out << '```'
      @out << "\n"
      if !node.is_last_child
        indent
        @out << "\n"
      end
    end

    def visit_paragraph(node)
      if !node.is_first_child
        indent
      end

      node.children_accept(self)
      @out << "\n"
      if !node.nested || ((node.parent.instance_of?(ListItem) && node.next.instance_of?(Paragraph)) && !node.is_last_child)
        @out << "\n"
      elsif node.parent.instance_of?(BlockQuote) && node.next.instance_of?(Paragraph)
        indent
        @out << "\n"
      end
    end

    def visit_blockelement(node)
      if !node.is_first_child
        indent
      end
      node.children_accept(self)
      @out << "\n"
      if !node.nested || (node.parent.instance_of? ListItem && (node.next.instance_of? Paragraph) && !node.is_last_child())
        @out << "\n"
      elsif node.parent.instance_of?(BlockQuote) && node.next.instance_of?(Paragraph)
        indent
        @out << "\n"
      end
    end

    def visit_image(node)
      @out << '[image: '
      node.children_accept(self)
      @out << ']'
      if node.value && node.value.strip.length > 0
        @out << '('
        @out << escape_url(node.value)
        @out << ')'
      end
    end

    def visit_link(node)
      @out << '['
      node.children_accept(self)
      @out << ']'
      if node.value && node.value.strip.length > 0
        @out << '('
        @out << escape_url(node.value)
        @out << ')'
      end
    end

    def visit_text(node)
      if node.parent.instance_of? Code
        @out << node.value.to_s;
      else
        @out << escape(node.value.to_s);
      end
    end

    def visit_strong(node)
      @out << '*'
      node.children_accept(self)
      @out << '*'
    end

    def visit_em(node)
      @out << '_'
      node.children_accept(self)
      @out << '_'
    end

    def visit_code(node)
      @out << '`'
      node.children_accept(self)
      @out << '`'
    end

    def visit_linebreak(node)
      @out << "\n"
      indent
    end

    def escape_url(text)
      return text.gsub(/\(/, "\\\\(")
                 .gsub(/\)/, "\\\\)")
    end

    def escape(text)
      return text.gsub(/\[/, "\\\\[")
                 .gsub(/\]/, "\\\\]")
                 .gsub(/\*/, "\\\\*")
                 .gsub(/_/, "\\\\_")
                 .sub(/`/, "\\\\`")
                 .sub(/=/, "\\\\=")
                 .sub(/>/, "\\\\>")
                 .sub(/-/, "\\\\-")
                 .sub(/(\d+)\./) { |m| "\\#{$1}." }
    end

    def indent
      @left.each { |s|
        @out << s
      }
    end

    def output
      @out.string.strip
    end
  end
end