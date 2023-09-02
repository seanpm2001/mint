module Mint
  class Ast
    class Call < Node
      getter arguments, expression

      def initialize(@arguments : Array(CallExpression),
                     @expression : Expression,
                     @file : Parser::File,
                     @from : Int64,
                     @to : Int64)
      end
    end
  end
end
