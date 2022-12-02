module Mint
  class TypeChecker
    def check(node : Ast::Value) : Checkable
      raise VariableReserved, {
        "name" => node.name,
        "node" => node,
      } if RESERVED.includes?(node.name)

      option =
        node.name.split('.').last

      entity =
        ast.records.find(&.name.==(node.name)) ||
          ast.enums.compact_map(&.options.find(&.value.==(option))).first?

      case entity
      when Ast::EnumOption
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
