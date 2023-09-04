module Mint
  class TypeChecker
    def check(node : Ast::Enum) : Checkable
      check_global_types node.name.value, node

      parameters =
        resolve node.parameters

      used_parameters = Set(Ast::TypeVariable).new

      node.options.each do |option|
        check option.parameters, node.parameters, used_parameters
      end

      node.parameters.each do |parameter|
        error! :enum_unused_parameter do
          block do
            text "The parameter"
            bold parameter.value
            text "was not used by any of the options."
          end

          block "Parameters must be used by at least one option."

          snippet parameter
        end unless used_parameters.includes?(parameter)
      end

      Type.new(node.name.value, parameters)
    end
  end
end
