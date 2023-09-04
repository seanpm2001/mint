module Mint
  class Formatter
    def format(node : Ast::TypeVariant)
      comment =
        node.comment.try { |item| "#{format item}\n" }

      parameters =
        format_parameters(node.parameters)

      "#{comment}#{format node.value}#{parameters}"
    end
  end
end
