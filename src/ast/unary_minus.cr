module Mint
  class Ast
    class UnaryMinus < Node
      getter expression, negations

      def initialize(@expression : Node,
                     @file : Parser::File,
                     @from : Int64,
                     @to : Int64)
      end
    end
  end
end
