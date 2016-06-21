class KoaraRenderer

  def visit_document(node)
    @left = Array.new
    @out = StringIO.new
    node.children_accept(self)
  end

  def visit_heading(node)
    if node.is_first_child
      indent
    end
    node.value.times {
      @out << "="
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
# 			out.append("> ");
# 			left.push("> ");
# 			node.childrenAccept(this);
# 			left.pop();
# 		} else {
# 			out.append(">\n");
    end
# 		if(!node.isNested()) {
# 			out.append("\n");
# 		}
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

#
# 	@Override
# 	public void visit(CodeBlock node) {
# 		StringBuilder indent = new StringBuilder();
# 		for(String s : left) {
# 			indent.append(s);
# 		}
#
# 		out.append("```");
# 		if(node.getLanguage() != null) {
# 			out.append(node.getLanguage());
# 		}
# 		out.append("\n");
# 		out.append(node.getValue().toString().replaceAll("(?m)^", indent.toString()));
# 		out.append("\n");
# 		indent();
# 		out.append("```");
# 		out.append("\n");
# 		if(!node.isLastChild()) {
# 			indent();
# 			out.append("\n");
# 		}
# 	}
#
  def visit_paragraph(node)
    if !node.is_first_child
      indent
    end

    node.children_accept(self)
    @out << "\n"
    if !node.nested || (node.parent.instance_of?(ListItem) && node.next.instance_of?(Paragraph)) && !node.is_last_child
      @out << "\n"
    elsif node.parent.instance_of?(BlockQuote) && node.next.instance_of?(Paragraph)
      indent
      @out << "\n"
    end
  end

#
# 	@Override
# 	public void visit(BlockElement node) {
# 		if(!node.isFirstChild()) {
# 			indent();
# 		}
# 		node.childrenAccept(this);
# 		out.append("\n");
# 		if(!node.isNested() || (node.getParent() instanceof ListItem && (node.next() instanceof Paragraph) && !node.isLastChild())) {
# 			out.append("\n");
# 		} else if(node.getParent() instanceof BlockQuote && (node.next() instanceof Paragraph)) {
# 			indent();
# 			out.append("\n");
# 		}
# 	}
#
# 	@Override
# 	public void visit(Image node) {
# 		out.append("[image: ");
# 		node.childrenAccept(this);
# 		out.append("]");
# 		if(node.getValue() != null && node.getValue().toString().trim().length() > 0) {
# 			out.append("(");
# 			out.append(escapeUrl(node.getValue().toString()));
# 			out.append(")");
# 		}
# 	}
#
# 	@Override
# 	public void visit(Link node) {
# 		out.append("[");
# 		node.childrenAccept(this);
# 		out.append("]");
# 		if(node.getValue() != null && node.getValue().toString().trim().length() > 0) {
# 			out.append("(");
# 			out.append(escapeUrl(node.getValue().toString()));
# 			out.append(")");
# 		}
# 	}
#
  def visit_text(node)
    if node.parent.instance_of? Code
      @out << node.value.to_s;
    else
      @out << escape(node.value.to_s);
    end
  end

#
# 	@Override
# 	public void visit(Strong node) {
# 		out.append("*");
# 		node.childrenAccept(this);
# 		out.append("*");
# 	}
#
# 	@Override
# 	public void visit(Em node) {
# 		out.append("_");
# 		node.childrenAccept(this);
# 		out.append("_");
# 	}
#
  def visit_code(node)
    @out << '`'
# 		node.childrenAccept(this);
# 		out.append("`");
  end

  def visit_linebreak(node)
    @out << "\n"
    indent
  end

#
# 	public String escapeUrl(String text) {
# 		return text.replaceAll("\\(", "\\\\(")
# 				.replaceAll("\\)", "\\\\)");
# 	}
#
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
