module Mint
  class Compiler
    def _compile(node : Ast::Value) : String
      case x = value_lookup[node]?
      when Tuple(Ast::Node, Ast::Node | Nil)
        name =
          js.class_of(x[1].not_nil!)

        case x[1]
        when Ast::Provider
          if node.name == "subscriptions"
            return "#{name}._subscriptions"
          end
        end

        variable =
          js.variable_of(x[0])

        "#{name}.#{variable}"
      else
        case item = lookups[node]?
        when Ast::EnumOption
          name =
            js.class_of(item)

          args = %w[]

          fields =
            case a = item.parameters.first?
            when Ast::EnumRecordDefinition
              a
                .fields
                .each_with_index
                .reduce({} of String => String) do |memo, (field, index)|
                  memo[field.key.value] = "_#{args.size}"
                  args << "_#{args.size}"
                  memo
                end
            else
              args =
                item.parameters.map_with_index do |_, index|
                  "_#{index}"
                end
            end

          body =
            case x = fields
            in Array(String)
              "new #{name}(#{x.join(", ")})"
            in Hash(String, String)
              "new #{name}(#{js.object(x)})"
            end

          "(" + if args.empty?
            body
          else
            js.arrow_function(args, js.return(body))
          end + ")"
        when Ast::RecordDefinition
          name =
            js.class_of(item.name)

          args = %w[]

          fields =
            item
              .fields
              .each_with_index
              .reduce({} of String => String) do |memo, (field, index)|
                memo[field.key.value] = "_#{args.size}"
                args << "_#{args.size}"
                memo
              end

          body =
            "new #{name}(#{js.object(fields)})"

          "(" + if args.empty?
            body
          else
            js.arrow_function(args, js.return(body))
          end + ")"
        else
          _compile_variable(node)
        end
      end
    end
  end
end
