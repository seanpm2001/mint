module Mint
  class TypeChecker
    def check(node : Ast::TypeDefinition) : Checkable
      check_global_types node.name.value, node

      fields, mappings =
        case items = node.fields
        when Array(Ast::TypeDefinitionField)
          {
            items.to_h { |item| {item.key.value, resolve(item).as(Checkable)} },
            items.to_h { |item| {item.key.value, item.mapping.try(&.string_value)} },
          }
        else
          { {} of String => Checkable, {} of String => String? }
        end

      type = Record.new(node.name.value, fields, mappings)
      types[node] = type

      type
    end
  end
end
