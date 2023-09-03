module Mint
  class TypeChecker
    def check(node : Ast::ArrayAccess) : Checkable
      index =
        node.index

      expression =
        node.expression

      type =
        resolve expression

      case index
      in Ast::Node
        index_type =
          resolve index

        error! :array_access_index_not_number do
          block "The index of an array access is not a number."
          expected NUMBER, index_type
          snippet index
        end unless Comparer.compare(index_type, NUMBER)

        check_array_access(expression, type)
      in Int64
        if type.name == "Tuple"
          parameter =
            type.parameters[index]?

          error! :array_access_invalid_tuple do
            block do
              text "The tuple only has"
              bold type.parameters.size.to_s
              text "members, but you wanted to access the"
              bold ordinal(index)
            end

            snippet "The exact type of the tuple is:", type
            snippet "The tuple is here:", expression
          end unless parameter

          parameter
        else
          check_array_access(expression, type)
        end
      end
    end

    def check_array_access(expression, type)
      error! :array_access_not_an_array do
        block "The object you are trying to access an item of is not an array."
        expected ARRAY, type
        snippet "The array is here:", expression
      end unless resolved = Comparer.compare(type, ARRAY)

      Type.new("Maybe", [resolved.parameters.first] of Checkable)
    end
  end
end
