module Mint
  class Compiler
    def _compile(node : Ast::Variable) : String
      entity, parent = variables[node]

      # Subscriptions for providers are handled here
      if node.value == "subscriptions" && parent.is_a?(Ast::Provider)
        return "this._subscriptions"
      end

      case parent
      when Tuple(String, TypeChecker::Checkable, Ast::Node)
        js.variable_of(parent[2])
      else
        case entity
        when Ast::Component, Ast::HtmlElement
          case parent
          when Ast::Component
            ref =
              parent
                .refs
                .find { |(ref, _)| ref.value == node.value }
                .try { |(ref, _)| js.variable_of(ref) }

            "this.#{ref}"
          else
            raise "SHOULD NOT HAPPEN"
          end
        when Ast::Function
          function =
            js.variable_of(entity.as(Ast::Node))

          x =
            ast.unified_modules.find(&.functions.find(&.==(entity))) ||
              ast.stores.find(&.functions.find(&.==(entity)))

          case x
          when Ast::Module, Ast::Store
            name =
              js.class_of(x.as(Ast::Node))

            "#{name}.#{function}"
          else
            "this.#{function}"
          end
        when Ast::Property, Ast::Get, Ast::State, Ast::Constant
          name =
            js.variable_of(entity.as(Ast::Node))

          case parent
          when Ast::Suite
            # The variable is a constant in a test suite
            "constants.#{name}()"
          else
            "this.#{name}"
          end
        when Ast::Argument
          js.variable_of(entity)
        else
          "this.#{node.value}"
        end
      end
    end
  end
end
