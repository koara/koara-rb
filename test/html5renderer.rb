require_relative '../lib/ast/document'
require_relative '../lib/ast/blockelement'
require_relative '../lib/ast/listitem'
class Html5Renderer

  #    private int level

  def visit_document(node)
    @level = 0
    @list_sequence = Array.new
    @out = StringIO.new
    node.children_accept(self)
  end

  def visit_heading(node)
    @out << indent + '<h' + node.value.to_s + '>'
    node.children_accept(self)
    @out << '</h' + node.value.to_s + ">\n"
    unless node.nested
      @out << "\n"
    end
  end

  def visit_blockquote(node)
    @out << indent + '<blockquote>'
    if !node.children.nil? && !node.children.empty
      @out << "\n"
    end
    @level += 1
    node.children_accept(slef)
    @level-=1
    @out << indent + "</blockquote>\n"
    if !node.nested
      @out << "\n"
    end
  end

  def visit_list_block(node)
    @list_sequence.push(0)
    tag = node.ordered ? 'ol' : 'ul'
    @out << "#{indent}<#{tag}>\n"
    @level += 1
    node.children_accept(self)
    @level -= 1
    @out << "#{indent}</#{tag}>\n"
    if !node.nested
      @out << "\n"
    end
    @list_sequence.pop
  end

  def visit_list_item(node)
    seq = @list_sequence.last.to_i + 1
    @list_sequence[-1] = seq
    @out << "#{indent}<li"

    if node.number && seq != node.number.to_i
      @out << " value=\"#{node.number}\""
      @list_sequence.push(node.number)
    end
    @out << '>'
    if !node.children.nil?
      block = node.children[0].instance_of?(Paragraph) || node.children[0].instance_of?(BlockElement)
      if (node.children.length > 1 || !block)
        @out << "\n"
      end
      @level += 1
      node.children_accept(self)
      @level -= 1
      if (node.children.length > 1 || !block)
        @out << indent
      end
    end
    @out << "</li>\n"
  end

  def visit_code_block(node)
    #      out.append(indent() + "<pre><code")
    #      if(node.getLanguage() != null) {
    #        out.append(" class=\"language-" + escape(node.getLanguage()) + "\"")
    #      }
    #      out.append(">")
    #      out.append(escape(node.getValue().toString()) + "</code></pre>\n")
    #      if(!node.isNested()) { out.append("\n") }
  end

  def visit_paragraph(node)
    if node.nested && node.parent.instance_of?(ListItem) && node.is_single_child
      node.children_accept(self)
    else
      @out << indent + '<p>'
      node.children_accept(self)
      @out << "</p>\n"
      unless node.nested
        @out << "\n"
      end
    end
  end

  def visit_block_element(node)
    if node.nested && node.parent.instance_of?(ListItem) && node.is_single_child
      node.children_accept(self)
    else
      @out << indent
      #        node.childrenAccept(this)
      #        if(!node.isNested()) { out.append("\n") }
    end
  end

  def visit_image(node)
    #      out.append("<img src=\"" + escapeUrl(node.getValue().toString()) + "\" alt=\"")
    #      node.childrenAccept(this)
    #      out.append("\" />")
  end

  def visit_link(node)
    #      out.append("<a href=\"" + escapeUrl(node.getValue().toString()) + "\">")
    #      node.childrenAccept(this)
    #      out.append("</a>")
  end

  def visit_strong(node)
    @out << '<strong>'
    node.children_accept(self)
    @out << '</strong>'
  end

  def visit_em(node)
    @out << '<em>'
    node.children_accept(self)
    @out << '</em>'
  end

  def visit_code(node)
    @out << '<code>'
    node.children_accept(self)
    @out << '</code>'
  end

  def visit_text(node)
    @out << escape(node.value.to_s)
  end

  #
  def escape(text)
    return text.gsub(/&/, '&amp;')
               .gsub(/</, '&lt;')
               .gsub(/>/, '&gt;')
               .gsub(/"/, '&quot;')
  end

  def visit(node)
    @out << "<br>\n" + indent
    node.children_accept(self)
  end

  def escape_url(text)
    #      return text.replaceAll(" ", "%20")
    #          .replaceAll("\"", "%22")
    #          .replaceAll("`", "%60")
    #          .replaceAll("<", "%3C")
    #          .replaceAll(">", "%3E")
    #          .replaceAll("\\[", "%5B")
    #          .replaceAll("\\]", "%5D")
    #          .replaceAll("\\\\", "%5C")
  end

  def indent
    #5.times { send_sms_to("xxx") }

    repeat = @level * 2
    str = StringIO.new

    repeat.times {
      str << ' '
    }

    #        final char[] buf = new char[repeat]
    #      for (int i = repeat - 1 i >= 0 i--) {
    #       buf[i] = ' '
    #      }
    #      return new String(buf)
    str.string
  end

  def output
    @out.string.strip
  end

end