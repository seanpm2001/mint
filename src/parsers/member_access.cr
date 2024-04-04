module Mint
  class Parser
    def member_access : Ast::MemberAccess?
      parse do |start_position|
        next unless char! '.'

        next error :member_access_expected_variable do
          expected "the field of the accessed entity of a member access", word
          snippet self
        end unless name = variable

        whitespace
        next error :memeber_access_expected_opening_parentheses do
          expected "the opening parentheses of a member access", word
          snippet self
        end unless char! '('

        whitespace
        next error :memeber_access_expected_type do
          expected "the type of a member access", word
        end unless type = self.type

        whitespace
        next error :memeber_access_expected_closing_parentheses do
          expected "the closing parentheses of a member access", word
          snippet self
        end unless char! ')'

        Ast::MemberAccess.new(
          from: start_position,
          to: position,
          type: type,
          file: file,
          name: name)
      end
    end
  end
end
