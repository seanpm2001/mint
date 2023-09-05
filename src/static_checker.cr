module Mint
  module StaticChecker
    def static?(nodes : Array(Ast::Node))
      nodes.all? { |node| static?(node) }
    end

    def static?(node : Ast::Node?)
      case node
      when Ast::StringLiteral,
           Ast::HereDocument
        node.value.all?(String)
      when Ast::HtmlAttribute
        static?(node.value)
      when Ast::Block
        static?(node.statements)
      when Ast::Statement
        static?(node.expression)
      when Ast::HtmlComponent
        node.ref.nil? &&
          static?(node.children) &&
          static?(node.attributes)
      when Ast::HtmlElement
        node.ref.nil? &&
          node.styles.empty? &&
          static?(node.children) &&
          static?(node.attributes)
      when Ast::HtmlExpression
        static?(node.expressions)
      when Ast::RegexpLiteral,
           Ast::NumberLiteral,
           Ast::BoolLiteral
        true
      when Ast::TupleLiteral,
           Ast::ArrayLiteral
        static?(node.items)
      else
        false
      end
    end

    def static_value(nodes : Array(Ast::Node), separator : Char? = nil)
      nodes.join(separator) { |node| static_value(node) }
    end

    def static_value(node : Ast::Node?)
      return unless static?(node)

      case node
      when Ast::StringLiteral,
           Ast::HereDocument
        node.value.select(String).join
      when Ast::HtmlAttribute
        "#{node.name.value}=#{static_value(node.value)}"
      when Ast::HtmlExpression
        static_value(node.expressions)
      when Ast::Block
        static_value(node.statements)
      when Ast::Statement
        static_value(node.expression)
      when Ast::RegexpLiteral
        "/#{node.value}/#{node.flags.split.uniq.join}"
      when Ast::TupleLiteral,
           Ast::ArrayLiteral
        "[#{static_value(node.items, ',')}]"
      when Ast::NumberLiteral,
           Ast::BoolLiteral
        node.value.to_s
      when Ast::HtmlElement
        node.tag.value +
          static_value(node.attributes) +
          static_value(node.children)
      when Ast::HtmlComponent
        node.component.value +
          static_value(node.attributes) +
          static_value(node.children)
      end
    end
  end
end
