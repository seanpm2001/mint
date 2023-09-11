module Mint
  class Compiler2
    def resolve(node : Ast::Block, imports : Imports) : JsNode
      statements =
        node
          .expressions
          .select(Ast::Statement)
          .sort_by! { |item| artifacts.resolve_order.index(item) || -1 }
          .flat_map { |item| compile(item, imports) }

      last =
        statements.pop

      if statements.empty? && !async?(node)
        if node.parent
          JsReturn.new(last)
        else
          last
        end
      elsif node.parent
        JsStatements.new(statements + [JsReturn.new(last)])
      elsif async?(node)
        JsAsyncIIF.new(statements + [JsReturn.new(last)])
      else
        JsIIF.new(statements + [JsReturn.new(last)])
      end
    end
  end
end
