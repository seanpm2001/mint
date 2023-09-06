module Mint
  class TypeChecker
    def check(node : Ast::TypeDefinition) : Checkable
      case items = node.fields
      in Array(Ast::TypeDefinitionField)
        fields =
          items.to_h { |item| {item.key.value, resolve(item).as(Checkable)} }

        mappings =
          items.to_h { |item| {item.key.value, static_value(item.mapping)} }

        type = Record.new(node.name.value, fields, mappings)

        Comparer.normalize(type)
      in Array(Ast::TypeVariant)
        parameters =
          resolve node.parameters

        used_parameters = Set(Ast::TypeVariable).new

        items.each do |option|
          check option.parameters, node.parameters, used_parameters
        end

        node.parameters.each do |parameter|
          error! :type_definition_unused_parameter do
            block do
              text "The parameter"
              bold parameter.value
              text "was not used by any of the options."
            end

            block "Parameters must be used by at least one option."

            snippet parameter
          end unless used_parameters.includes?(parameter)
        end

        Comparer.normalize(Type.new(node.name.value, parameters))
      end
    end

    def check(parameters : Array(Ast::Node),
              names : Array(Ast::TypeVariable),
              used_parameters : Set(Ast::TypeVariable))
      parameters.each do |parameter|
        case parameter
        when Ast::Type
          check parameter.parameters, names, used_parameters
        when Ast::TypeVariable
          param =
            names.find(&.value.==(parameter.value))

          error! :type_definition_not_defined_parameter do
            block do
              text "The parameter"
              bold parameter.value
              text "was not defined in the type of the type definition."
            end

            block "Parameters used by options must be defined in the type of the type definition."

            snippet parameter
          end unless param

          used_parameters.add param
        end
      end
    end
  end
end
