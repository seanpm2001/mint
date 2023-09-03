module Mint
  class Ast
    class CallExpression < Node
      getter name, expression

      def initialize(@file : Parser::File,
                     @expression : Node,
                     @name : Variable?,
                     @from : Int64,
                     @to : Int64)
      end
    end
  end
end
