# encoding: utf-8

class Html5Renderer

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
    if !node.children.nil? && node.children.any?
      @out << "\n"
    end
    @level += 1
    node.children_accept(self)
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
      block = node.children[0].instance_of?(Koara::Ast::Paragraph) || node.children[0].instance_of?(Koara::Ast::BlockElement)
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

  def visit_codeblock(node)
    @out << indent + '<pre><code'
    if node.language
      @out << " class=\"language-" + escape(node.language) + "\""
    end
    @out << '>'
    @out << escape(node.value) + "</code></pre>\n"
    @out << ("\n") if !node.nested
  end

  def visit_paragraph(node)
    if node.nested && node.parent.instance_of?(Koara::Ast::ListItem) && node.is_single_child
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
    if node.nested && node.parent.instance_of?(Koara::Ast::ListItem) && node.is_single_child
      node.children_accept(self)
    else
      @out << indent
      node.children_accept(self)
      if !node.nested
        @out << "\n"
      end
    end
  end

  def visit_image(node)
    @out << "<img src=\"" + escape_url(node.value) + "\" alt=\""
    node.children_accept(self)
    @out << "\" />"
  end

  def visit_link(node)
    @out << "<a href=\"" + escape_url(node.value) + "\">"
    node.children_accept(self)
    @out << '</a>'
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

  def visit_linebreak(node)
    @out << "<br>\n" + indent
    node.children_accept(self)
  end

  def escape_url(text)
    text.gsub(/ /, '%20')
        .gsub(/"/, '%22')
        .gsub(/`/, '%60')
        .gsub(/</, '%3C')
        .gsub(/>/, '%3E')
        .gsub(/\[/, '%5B')
        .gsub(/\]/, '%5D')
        .gsub(/\\/, '%5C')
  end

  def indent
    repeat = @level * 2
    str = StringIO.new
    repeat.times {
      str << ' '
    }
    str.string
  end

  def output
    @out.string.strip
  end
end