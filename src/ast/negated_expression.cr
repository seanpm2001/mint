module Mint
  class Ast
    class NegatedExpression < Node
      getter expression, negations

      def initialize(@expression : Expression,
                     @negations : String,
                     @file : Parser::File,
                     @from : Int32,
                     @to : Int32)
      end
    end
  end
end
