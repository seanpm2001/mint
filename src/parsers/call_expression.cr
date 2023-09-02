module Mint
  class Parser
    def call_expression : Ast::CallExpression?
      parse do |start_position|
        name =
          parse(track: false) do
            next unless key = variable
            whitespace

            next unless char! ':'
            whitespace

            key
          end

        return unless expression = self.expression

        Ast::CallExpression.new(
          expression: expression,
          from: start_position,
          to: position,
          file: file,
          name: name)
      end
    end
  end
end
