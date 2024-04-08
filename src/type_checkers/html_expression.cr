module Mint
  class TypeChecker
    def check(node : Ast::HtmlExpression) : Checkable
      type =
        resolve node.expression

      error! :html_expression_type_mismatch do
        block "The expression of an HTML expression has an invalid type."
        block "I was expecting one of the following types:"

        snippet VALID_HTML.map(&.to_mint).join("\n")
        snippet "Instead it is:", type
        snippet node.expression
      end unless Comparer.matches_any?(type, VALID_HTML)

      HTML
    end
  end
end
