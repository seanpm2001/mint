module Mint
  class Compiler2
    def resolve(node : Ast::Variable, imports : Imports) : JsNode
      if node.value == "void"
        JsValue.new("null")
      else
        entity, parent = artifacts.variables[node]

        case {entity, parent}
        # when {Ast::Variable, Ast::Block},
        #      {Ast::Variable, Ast::Statement},
        #      {Ast::Variable, Ast::For},
        #      {Ast::Variable, Ast::CaseBranch},
        #      {Ast::Spread, Ast::CaseBranch}
        #   js.variable_of(entity)
        # when {Ast::Component, Ast::Component},
        #      {Ast::HtmlElement, Ast::Component}
        #   case parent
        #   when Ast::Component
        #     ref =
        #       parent
        #         .refs
        #         .find { |(ref, _)| ref.value == node.value }
        #         .try { |(ref, _)| js.variable_of(ref) }

        #     "this.#{ref}"
        #   else
        #     raise "SHOULD NOT HAPPEN"
        #   end
        # when {Ast::ConnectVariable, _}
        #   "this.#{js.variable_of(entity)}"
        else
          item =
            JsId.new(compile(entity, imports))

          case entity
          when Ast::Function
            case parent
            when Ast::Module
              unless node.stack.includes?(parent)
                puts parent
                compile(parent)
                imports.add({from: compile(parent), what: item})
              end
              item
            when Ast::Store
              # name =
              #   compile(parent)

              # JsAccess.new(name, function)
              JsAccess.new(JsValue.new("this"), item)
            else
              JsAccess.new(JsValue.new("this"), item)
            end
          when Ast::Property, Ast::Get, Ast::State, Ast::Constant
            case parent
            when Ast::Suite
              JsAccess.new(JsValue.new("constants"), item)
            else
              JsAccess.new(JsValue.new("this"), item)
            end
          when Ast::Argument
            item
          else
            JsAccess.new(JsValue.new("this"), JsValue.new(node.value))
          end
        end
      end
    end
  end
end
