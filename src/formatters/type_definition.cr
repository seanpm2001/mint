module Mint
  class Formatter
    def format(node : Ast::TypeDefinition) : String
      name =
        format node.name

      fields =
        format node.fields, ",\n"

      comment =
        node.comment.try { |item| "#{format(item)}\n" }.to_s

      "#{comment}type #{name} {\n#{indent(fields)}\n}"
    end
  end
end
