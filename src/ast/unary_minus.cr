module Mint
  class Ast
    class UnaryMinus < Node
      getter expression, negations

      def initialize(@expression : Expression,
                     @file : Parser::File,
                     @from : Int32,
                     @to : Int32)
      end
    end
  end
end
