module Mint
  class Ast
    class CallExpression < Node
      getter name, expression

      def initialize(@expression : Expression,
                     @name : Variable?,
                     @file : Parser::File,
                     @from : Int32,
                     @to : Int32)
      end
    end
  end
end
