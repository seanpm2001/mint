module Mint
  class Parser
    def unary_minus : Ast::UnaryMinus?
      parse do |start_position|
        next unless char! '-'

        expression = self.expression

        next unless expression

        Ast::UnaryMinus.new(
          expression: expression,
          from: start_position,
          to: position,
          file: file)
      end
    end
  end
end
