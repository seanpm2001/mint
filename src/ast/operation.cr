module Mint
  class Ast
    class Operation < Node
      getter left, right, operator

      def initialize(@right : Expression,
                     @left : Expression,
                     @operator : String,
                     @file : Parser::File,
                     @from : Int64,
                     @to : Int64)
      end
    end
  end
end
