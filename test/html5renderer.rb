class Html5Renderer

  #    private int level

  def visit_document(node)
    @list_sequence = Array.new
    @out = StringIO.new
    node.children_accept(self)
  end

  def visit_heading(node)
    @out << indent + '<h' + node.value + '>'
    node.children_accept(self)
    @out << '</h' + node.value + ">\n"
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

  def visit_list(node)
    @list_sequence.push(0)
    tag = node.ordered ? 'ol' : 'ul'
    @out << "#{indent}<#{tag}>\n"
    @level += 1
    node.children_accept(self)
    @level -= 1
    #      out.append(indent() + "</" + tag + ">\n")
    #      if(!node.isNested()) { out.append("\n") }
    @list_sequence.pop
  end

  def visit_list_item(node)
    #      Integer seq = listSequence.peek() + 1
    #      listSequence.set(listSequence.size() - 1, seq)
    #      out.append(indent() + "<li")
    #      if(node.getNumber() != null && (!seq.equals(node.getNumber()))) {
    #        out.append(" value=\"" + node.getNumber() + "\"")
    #        listSequence.push(node.getNumber())
    #      }
    #      out.append(">")
    #      if(node.getChildren() != null) {
    #        boolean block = (node.getChildren()[0].getClass() == Paragraph.class || node.getChildren()[0].getClass() == BlockElement.class)
    #
    #        if(node.getChildren().length > 1 || !block) { out.append("\n") }
    #        level++
    #        node.childrenAccept(this)
    #        level--
    #        if(node.getChildren().length > 1 || !block) { out.append(indent()) }
    #      }
    #      out.append("</li>\n")
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
    #      if(node.isNested() && (node.getParent() instanceof ListItem) && node.isSingleChild()) {
    #        node.childrenAccept(this)
    #      } else {
    @out << indent + '<p>'
    node.children_accept(self)
    @out << "</p>\n"
    unless node.nested
      @out << "\n"
    end
  end

  def visit_block_element(node)
    #      if(node.isNested() && (node.getParent() instanceof ListItem) && node.isSingleChild()) {
    #        node.childrenAccept(this)
    #      } else {
    #        out.append(indent())
    #        node.childrenAccept(this)
    #        if(!node.isNested()) { out.append("\n") }
    #      }
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
    #      return text.replaceAll("&", "&amp")
    #          .replaceAll("<", "&lt")
    #          .replaceAll(">", "&gt")
    #          .replaceAll("\"", "&quot")
    text
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
    #      int repeat = level * 2
    #        final char[] buf = new char[repeat]
    #      for (int i = repeat - 1 i >= 0 i--) {
    #       buf[i] = ' '
    #      }
    #      return new String(buf)
    ""
  end

  def output
    @out.string.strip
  end

end