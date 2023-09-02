module Mint
  class Ast
    class ParenthesizedExpression < Node
      getter expression

      def initialize(@expression : Node,
                     @file : Parser::File,
                     @from : Int64,
                     @to : Int64)
      end
    end
  end
end
