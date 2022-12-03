module Mint
  class Compiler
    def _compile(node : Ast::Access) : String
      first =
        compile node.lhs

      case lookups[node]?
      when Ast::Provider
        if node.field.value == "subscriptions"
          return "#{first}._subscriptions"
        end
      end

      field =
        if record_field_lookup[node.field]?
          node.field.value
        else
          js.variable_of(lookups[node.field])
        end

      "#{first}.#{field}"
    end
  end
end
