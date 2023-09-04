module Mint
  class Parser
    def access(expression : Ast::Node) : Ast::Access?
      parse do
        type =
          if word! "::"
            # TODO: puts "[Deprecation] Enum access will be deprecated in the next release. Use a dot '.' instead of a double colon '::'"
            Ast::Access::Type::DoubleColon
          elsif char! ':'
            # TODO: puts "[Deprecation] Constant access will be deprecated in the next release. Use a dot '.' instead of a colon ':'"
            Ast::Access::Type::Colon
          elsif char! '.'
            Ast::Access::Type::Dot
          end

        next unless type

        next error :access_expected_entity do
          expected "the name of the accessed entity", word
          snippet self
        end unless field = value

        Ast::Access.new(
          expression: expression,
          from: expression.from,
          field: field,
          to: position,
          file: file,
          type: type)
      end
    end
  end
end
