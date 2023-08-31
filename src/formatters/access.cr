module Mint
  class Formatter
    def format(node : Ast::Access) : String
      expression =
        format node.expression

      separator =
        case node.type
        when Ast::Access::Type::Colon
          ":"
        when Ast::Access::Type::Dot
          "."
        when Ast::Access::Type::DoubleColon
          "::"
        end

      "#{expression}#{separator}#{node.field.value}"
    end
  end
end
