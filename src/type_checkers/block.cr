module Mint
  class TypeChecker
    def check(node : Ast::Block) : Checkable
      statements =
        node.statements.select(Ast::Statement)

      with_returns(node) do
        statements.dup.tap do |items|
          variables = [] of VariableScope

          while item = items.shift?
            variables.each do |var|
              scope.add(node, var[0], var[2])
            end

            # This is to allow recursion
            case target = item.target
            when Ast::Variable
              case value = item.expression
              when Ast::InlineFunction
                cache[target] =
                  static_type_signature(value)

                scope.add(item, target.value, target)
              end
            end

            type = resolve item
            variables = destructure(item.target, type)
          end
        end

        last =
          cache[statements.last]

        error! :statement_last_target do
          block do
            text "The"
            bold "last statement"
            text "of a block cannot be an"
            bold "assignment"
            text "."
          end

          snippet node
        end if statements.last.target

        if returns = @returns[node]?
          returns.each do |item|
            type =
              cache[item]

            error! :statement_return_type_mismatch do
              block "The type of a return call does not match the return type of the block."

              expected last, type
              snippet "It is here:", item
            end unless Comparer.compare(last, type)
          end
        end

        if node.async? && last.name != "Promise"
          Type.new("Promise", [last] of Checkable)
        else
          last
        end
      end
    end
  end
end
