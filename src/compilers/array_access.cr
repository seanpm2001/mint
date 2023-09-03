module Mint
  class Compiler
    def _compile(node : Ast::ArrayAccess) : String
      type =
        cache[node.expression]

      expression =
        compile node.expression

      index =
        case node.index
        when Int64
          node.index
        when Ast::Node
          compile node.index.as(Ast::Node)
        end

      if type.name == "Tuple" && node.index.is_a?(Int64)
        "#{expression}[#{index}]"
      else
        "_at(#{expression}, #{index})"
      end
    end
  end
end
