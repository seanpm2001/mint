module Mint
  class Parser
    def call(expression : Ast::Node) : Ast::Call?
      parse do |start_position|
        next unless char! '('
        whitespace

        arguments = list(
          terminator: ')',
          separator: ','
        ) { field(key_required: false) }

        whitespace
        next error :call_expected_closing_parenthesis do
          block do
            text "The"
            bold "arguments"
            text "of a"
            bold "call"
            text "must be enclosed by parenthesis."
          end

          expected "the closing parenthesis of a call", word
          snippet self
        end unless char! ')'

        Ast::Call.new(
          from: start_position,
          arguments: arguments,
          expression: expression,
          to: position,
          file: file)
      end
    end
  end
end
