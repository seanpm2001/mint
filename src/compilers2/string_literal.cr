module Mint
  class Compiler2
    def resolve(node : Ast::StringLiteral, imports : Imports) : JsNode
      items =
        node.value.map do |item|
          case item
          in Ast::Node
            JsInterpolation.new(compile(item, imports))
          in String
            JsValue.new(item)
          end
        end

      JsTemplateLiteral.new(items)
    end
  end
end
