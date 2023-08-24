module Mint
  class Parser
    def expression : Ast::Expression?
      return unless left = basic_expression

      if operator = self.operator
        rollup_pipe operation(left, operator)
      else
        left
      end
    end
  end
end
