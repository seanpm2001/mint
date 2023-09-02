module Mint
  class Ast
    class Call < Node
      getter arguments, expression

      def initialize(@arguments : Array(CallExpression),
                     @expression : Node,
                     @file : Parser::File,
                     @from : Int64,
                     @to : Int64)
      end
    end
  end
end
