module Mint
  class Formatter
    def format(node : Ast::ArrayAccess) : String
      index =
        case node.index
        when Int64
          node.index
        else
          format node.index.as(Ast::Node)
        end

      expression =
        format node.expression

      "#{expression}[#{index}]"
    end
  end
end
