module Mint
  class TypeChecker
    def find_entity(name : String) : Tuple(Ast::Node, Ast::Node?)?
      if name.includes?('.')
        parts = name.split(".")
        tail = parts.pop
        head = parts.join(".")

        item =
          case entity = find_simple_entity(head)
          when Ast::Enum
            entity.options.find(&.value.==(tail))
          when Ast::Module
            entity.functions.find(&.name.value.==(tail)) ||
              entity.constants.find(&.name.==(tail))
          when Ast::Component
            entity.functions.find(&.name.value.==(tail)) ||
              entity.gets.find(&.name.value.==(tail)) ||
              entity.states.find(&.name.value.==(tail)) ||
              entity.constants.find(&.name.==(tail))
          when Ast::Store
            entity.functions.find(&.name.value.==(tail)) ||
              entity.gets.find(&.name.value.==(tail)) ||
              entity.states.find(&.name.value.==(tail)) ||
              entity.constants.find(&.name.==(tail))
          end

        if item
          {item, entity}
        elsif entity
          {entity, nil}
        end
      else
        item = find_simple_entity(name)
        {item, nil} if item
      end
    end

    def find_simple_entity(name)
      ast.records.find(&.name.==(name)) ||
        ast.components.find(&.name.==(name)) ||
        ast.stores.find(&.name.==(name)) ||
        ast.unified_modules.find(&.name.==(name)) ||
        ast.enums.compact_map(&.options.find(&.value.==(name))).first? ||
        ast.enums.find(&.name.==(name))
    end

    def check(node : Ast::Value) : Checkable
      raise VariableReserved, {
        "name" => node.name,
        "node" => node,
      } if RESERVED.includes?(node.name)

      x =
        find_entity(node.name)

      case entity = x.try(&.first)
      when Ast::Constant
        value_lookup[node] = x.not_nil!

        if y = x.not_nil![1]
          check!(y)
          scope y do
            resolve(entity)
          end
        else
          resolve(entity)
        end
      when Ast::EnumOption
        option =
          node.name.split('.').last

        item =
          ast.enums.find(&.options.find(&.value.==(option))).not_nil!

        enum_type =
          resolve(item)

        lookups[node] = entity

        if !entity.parameters.empty?
          option_type = resolve(entity)

          case defi = entity.parameters.first?
          when Ast::EnumRecordDefinition
            enum_constructor_data[node] = {resolve(defi).as(Record), enum_type.as(Type)}
          end

          Comparer.normalize(Type.new("Function", option_type.parameters + [enum_type]))
        else
          enum_type
        end
      when Ast::RecordDefinition
        lookups[node] = entity

        case record_type = resolve(entity)
        when Record
          Type.new("Function", record_type.fields.values + [record_type])
        else
          raise TypeError # Should not happen
        end
      else
        check(node.name, node)
      end
    end
  end
end
