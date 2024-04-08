module Mint
  class Parser
    def html_expression : Ast::HtmlExpression?
      parse do |start_position|
        next unless word! "<{"

        whitespace
        next error :html_expression_expected_expression do
          expected "the expression of an HTML expression", word
          snippet self
        end unless expression = self.expression

        whitespace
        next error :html_expression_expected_closing_tag do
          expected "the closing tag of an HTML expression", word
          snippet self
        end unless word! "}>"

        Ast::HtmlExpression.new(
          expression: expression,
          from: start_position,
          to: position,
          file: file)
      end
    end
  end
end
