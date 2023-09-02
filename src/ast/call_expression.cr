module Mint
  class Ast
    class CallExpression < Node
      getter name, expression

      def initialize(@expression : Node,
                     @name : Variable?,
                     @file : Parser::File,
                     @from : Int64,
                     @to : Int64)
      end
    end
  end
end
