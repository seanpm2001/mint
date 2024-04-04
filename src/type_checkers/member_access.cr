module Mint
  class TypeChecker
    def check(node : Ast::MemberAccess) : Checkable
      case type = resolve node.type
      when Record
        field =
          type.fields[node.name.value]?

        error! :member_access_field_not_found do
          block do
            text "The field"
            bold node.name.value
            text "does not exists on the type:"
          end

          snippet type
          snippet "The access in question is here:", node
        end unless field

        Type.new("Function", [type, field] of Checkable)
      else
        error! :member_access_not_record do
          block "The type of the accessed entity is not a record."
          snippet "The access in question is here:", node
        end
      end
    end
  end
end
