module Mint
  class Compiler2
    def resolve(node : Ast::Access, imports : Imports) : JsNode
      if items = artifacts.variables[node]?
        case items[0]
        when Ast::TypeVariant
          JsSkip.new
          # name =
          #   JsId.id(compile(items[0], imports))

          # type =
          #   cache[node]?

          # case type
          # when nil
          #   JsSkip.new
          # else
          #   if type.name == "Function"
          #     "_n(#{name})"
          #   else
          #     "new #{name}()"
          #   end
          # end
        else
          id =
            case x = items[1]
            when Ast::Module
              JsId.new(compile(x))
            else
              JsSkip.new
            end

          # case items[1]
          # when Ast::Provider
          #   if node.field.value == "subscriptions"
          #     return "#{name}._subscriptions"
          #   end
          # end

          variable =
            JsId.new(compile(items[0].as(Ast::Node), imports))

          JsAccess.new(id, variable)
        end
      else
        target =
          compile node.expression, imports

        field =
          if artifacts.record_field_lookup[node.field]?
            JsValue.new(node.field.value)
          else
            JsId.new(compile(artifacts.lookups[node.field], imports))
          end

        JsAccess.new(target, field)
      end
    end
  end
end
