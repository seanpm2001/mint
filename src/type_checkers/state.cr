module Mint
  class TypeChecker
    def check(node : Ast::State) : Checkable
      default =
        with_restricted_top_level_entity(node) do
          resolve node.default
        end

      if item = node.type
        type =
          resolve item

        resolved =
          Comparer.compare(type, default)

        error! :state_type_mismatch do
          block do
            text "The type of the default value of the"
            bold node.name.value
            text "state does not match its type annotation."
          end

          expected type, default
          snippet node.default
        end unless resolved

        resolved
      else
        default
      end
    end
  end
end
