module Mint
  class Parser
    def access(expression : Ast::Expression) : Ast::Access?
      parse do
        type =
          if keyword "::"
            Ast::Access::Type::DoubleColon
          elsif char! '.'
            Ast::Access::Type::Dot
          elsif char! ':'
            Ast::Access::Type::Colon
          end

        next unless type

        next error :access_expected_entity do
          expected "the name of the accessed entity", word
          snippet self
        end unless field = variable || variable_constant

        self << Ast::Access.new(
          expression: expression,
          from: expression.from,
          field: field,
          to: position,
          input: data,
          type: type)
      end
    end
  end
end
