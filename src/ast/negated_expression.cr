module Mint
  class Ast
    class NegatedExpression < Node
      getter expression, negations

      def initialize(@expression : Node,
                     @negations : String,
                     @file : Parser::File,
                     @from : Int64,
                     @to : Int64)
      end
    end
  end
end
