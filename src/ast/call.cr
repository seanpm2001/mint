module Mint
  class Ast
    class Call < Node
      getter arguments, expression

      def initialize(@arguments : Array(CallExpression),
                     @expression : Expression,
                     @file : Parser::File,
                     @from : Int32,
                     @to : Int32)
      end
    end
  end
end
