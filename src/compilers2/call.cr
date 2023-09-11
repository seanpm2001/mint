module Mint
  class Compiler2
    def resolve(node : Ast::Call, imports : Imports) : JsNode
      expression =
        compile node.expression, imports

      arguments =
        compile node.arguments.sort_by { |item| artifacts.argument_order.index(item) || -1 }, imports

      case
      when node.expression.is_a?(Ast::InlineFunction)
        JsCall.new(expression, arguments)
        # { }"(#{expression})(#{arguments})"
      else
        JsCall.new(expression, arguments)
      end
    end
  end
end
