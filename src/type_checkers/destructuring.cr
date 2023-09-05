module Mint
  class TypeChecker
    # This file contains the logic for destructuring (aka pattern matching).
    # It's a recursive algorithm, traversing the destructuring tree and the
    # type tree simultaneously.
    #
    # - if one of the destructurings is a mismatch it errors out
    # - non destructuring nodes are resolved and compared with condition

    # An alias for the variable scope (of Mint::Typechecker::Scope)
    alias VariableScope = Tuple(String, Checkable, Ast::Node)

    def destructuring_type_mismatch(expected : Checkable, got : Checkable, node : Ast::Node)
      error! :destructuring_type_mismatch do
        block "A value does not match its supposed type."

        snippet "I was expecting:", expected
        snippet "Instead it is:", got

        snippet node
      end
    end

    def destructure(
      node : Nil,
      condition : Checkable,
      variables : Array(VariableScope) = [] of VariableScope
    )
      variables
    end

    def destructure(
      node : Ast::Node,
      condition : Checkable,
      variables : Array(VariableScope) = [] of VariableScope
    )
      type =
        resolve(node)

      destructuring_type_mismatch(
        expected: condition,
        node: node,
        got: type) unless Comparer.compare(type, condition)

      variables
    end

    # This is for the `let` statement when it's a single assignment
    def destructure(
      node : Ast::Variable,
      condition : Checkable,
      variables : Array(VariableScope) = [] of VariableScope
    )
      cache[node] = condition
      variables.tap(&.push({node.value, condition, node}))
    end

    def destructure(
      node : Ast::ArrayDestructuring,
      condition : Checkable,
      variables : Array(VariableScope) = [] of VariableScope
    )
      destructuring_type_mismatch(
        expected: ARRAY,
        got: condition,
        node: node,
      ) unless Comparer.compare(ARRAY, condition)

      spreads =
        node.items.select(Ast::Spread).size

      error! :destructuring_multiple_spreads do
        block do
          text "This array destructuring contains"
          code spreads.to_s
          text "spread notations."
        end

        block "An array destructuring can only contain one spread notation."

        snippet node
      end if spreads > 1

      node.items.each do |item|
        case item
        when Ast::Spread
          cache[item] = condition
          variables << {item.variable.value, condition, item}
        else
          destructure(item, condition.parameters[0], variables)
        end
      end

      variables
    end

    def destructure(
      node : Ast::TupleDestructuring,
      condition : Checkable,
      variables : Array(VariableScope) = [] of VariableScope
    )
      destructuring_type_mismatch(
        expected: Type.new("Tuple"),
        got: condition,
        node: node,
      ) unless condition.name == "Tuple"

      error! :destructuring_tuple_mismatch do
        block "This destructuring of a tuple does not match the given tuple."
        block do
          text "I was expecting a tuple with"
          bold node.items.size.to_s
          text "items."
        end

        snippet "Instead it is this:", condition

        snippet node
      end if node.items.size > condition.parameters.size

      node.items.each_with_index do |item, index|
        destructure(item, condition.parameters[index], variables)
      end

      variables
    end

    def destructure(
      node : Ast::TypeDestructuring,
      condition : Checkable,
      variables : Array(VariableScope) = [] of VariableScope
    )
      parent =
        ast.type_definitions.find(&.name.value.==(node.name.try &.value))

      error! :destructuring_type_missing do
        block do
          text "I could not find the type for a destructuring:"
          bold node.name.try(&.value).to_s
        end

        snippet node
      end unless parent

      variant =
        case fields = parent.fields
        when Array(Ast::TypeVariant)
          fields.find(&.value.value.==(node.variant.value))
        end

      error! :destructuring_type_option_missing do
        block do
          text "I could not find the variant"
          bold node.variant.value
          text "of type"
          bold parent.name.value
          text "for a destructuring."
        end

        snippet "You tried to reference it here:", node
        snippet "The type is defined here:", parent
      end unless variant

      lookups[node] = variant

      type = resolve(parent)

      unified =
        Comparer.compare(type, condition)

      destructuring_type_mismatch(
        expected: condition,
        node: node,
        got: type,
      ) unless unified

      case fields = variant.fields
      when Array(Ast::TypeDefinitionField)
        node.items.each_with_index do |param, index|
          case param
          when Ast::Variable
            found = fields.find do |field|
              case param
              when Ast::Variable
                param.value == field.key.value
              end
            end

            error! :destructuring_type_field_missing do
              block do
                text "I could not find the field"
                bold param.value
                text "for a destructuring."
              end

              snippet "You tried to reference it here:", param
            end unless found

            type =
              resolve(found.type)

            destructure(param, type, variables)
          else
            field =
              fields[index]

            type =
              resolve(field.type)

            destructure(param, type, variables)
          end
        end
      else
        node.items.each_with_index do |param, index|
          case param
          when Ast::Variable
            error! :destructuring_no_parameter do
              block do
                text "You are trying to destructure the"
                bold index.to_s
                text "parameter from the type variant:"
                bold variant.value.value
              end

              block do
                text "The variant only has"
                bold variant.parameters.size.to_s
                text "parameters."
              end

              snippet "You are trying to destructure it here:", param
              snippet "The option is defined here:", variant
            end unless variant.parameters[index]?

            variant_type =
              resolve(variant.parameters[index]).not_nil!

            mapping = {} of String => Checkable

            parent.parameters.each_with_index do |param2, index2|
              mapping[param2.value] = condition.parameters[index2]
            end

            resolved_type =
              Comparer.fill(variant_type, mapping).not_nil!

            destructure(param, resolved_type, variables)
          else
            sub_type =
              case item = variant.parameters[index]
              when Ast::Type
                resolve(item)
              when Ast::TypeVariable
                unified.parameters[parent.parameters.index! { |variable| variable.value == item.value }]
              else
                VOID # Can't happen
              end

            destructure(param, sub_type, variables)
          end
        end
      end

      variables
    end
  end
end
