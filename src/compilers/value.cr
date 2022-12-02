module Mint
  class Compiler
    def _compile(node : Ast::Value) : String
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
        entity, parent = variables[node]

        # Subscriptions for providers are handled here
        if node.name == "subscriptions" && parent.is_a?(Ast::Provider)
          return "this._subscriptions"
        end

        connected = nil

        case parent
        when Ast::Component
          parent.connects.each do |connect|
            store = ast.stores.find(&.name.==(connect.store))

            name =
              case entity
              when Ast::Function then entity.name.value
              when Ast::State    then entity.name.value
              when Ast::Get      then entity.name.value
              when Ast::Constant then entity.name
              end

            if store
              connect.keys.each do |key|
                if (store.functions.includes?(entity) ||
                   store.constants.includes?(entity) ||
                   store.states.includes?(entity) ||
                   store.gets.includes?(entity)) &&
                   key.variable.value == name
                  connected = key
                end
              end
            end
          end
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
                  .find { |(ref, _)| ref.value == node.name }
                  .try { |(ref, _)| js.variable_of(ref) }

              "this.#{ref}"
            else
              raise "SHOULD NOT HAPPEN"
            end
          when Ast::Function
            function =
              if connected
                js.variable_of(connected)
              else
                js.variable_of(entity.as(Ast::Node))
              end

            case parent
            when Ast::Module, Ast::Store
              name =
                js.class_of(parent.as(Ast::Node))

              "#{name}.#{function}"
            else
              "this.#{function}"
            end
          when Ast::Property, Ast::Get, Ast::State, Ast::Constant
            name =
              if connected
                js.variable_of(connected)
              else
                js.variable_of(entity.as(Ast::Node))
              end

            case parent
            when Ast::Suite
              # The variable is a constant in a test suite
              "constants.#{name}()"
            else
              "this.#{name}"
            end
          when Ast::Argument
            js.variable_of(entity)
          when Ast::Statement
            case target = entity.target
            when Ast::Variable
              js.variable_of(target)
            else
              "SHOULD NEVER HAPPEN"
            end
          when Tuple(Ast::Node, Array(Int32) | Int32)
            case item = entity[0]
            when Ast::Statement
              case target = item.target
              when Ast::TupleDestructuring
                case val = entity[1]
                in Int32
                  js.variable_of(target.parameters[val])
                in Array(Int32)
                  js.variable_of(val.reduce(target) do |curr_type, curr_val|
                    curr_type.as(Ast::TupleDestructuring).parameters[curr_val]
                  end)
                end
              else
                js.variable_of(node)
              end
            else
              js.variable_of(node)
            end
          else
            "this.#{node.name}"
          end
        end
      end
    end
  end
end
