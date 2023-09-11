module Mint
  class Compiler2
    def resolve(node : Ast::Statement, imports : Imports) : JsNode
      right, return_call =
        case expression = node.expression
        when Ast::Operation
          case item = expression.right
          when Ast::ReturnCall
            {
              compile(expression.left, imports),
              compile(item.expression, imports),
            }
          end
        end || {compile(node.expression, imports), nil}

      right = JsExpression.new(right, await: true) if node.await

      if target = node.target
        case target
        when Ast::Variable
          JsConstant.new(JsId.new(mapping[target] = JsVariable.new), right)
        when Ast::TupleDestructuring, Ast::TypeDestructuring, Ast::ArrayDestructuring
          variables = [] of String

          pattern =
            JsNode.new
          # destructuring(target, variables)

          case target
          when Ast::TupleDestructuring
            if target.items.all?(Ast::Variable)
              # TODO.....
              JsConstant.new(JsDestructuring.new([] of JsNode), right)
            end
          end || begin
            imports.add({from: runtime, what: runtime_exports[:destructure]})

            variable =
              JsNode.new

            const =
              JsConstant.new(variable, JsCall.new(runtime_exports[:destructure], [right, pattern]))

            return_if =
              if return_call
                JsIf.new(
                  condition: JsOperation.new("===", variable, JsValue.new("fase")),
                  thruthy: JsReturn.new(return_call))
              end

            destructuring =
              JsConstant.new(JsDestructuring.new([] of JsNode), right)

            JsStatements.new([
              const,
              return_if,
              destructuring,
            ].compact)
          end
        end
      end || right
    end
  end
end
