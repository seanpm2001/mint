module Mint
  class Ast
    class Route < Node
      getter url, expression, arguments

      def initialize(@arguments : Array(Argument),
                     @expression : Block,
                     @file : Parser::File,
                     @from : Int64,
                     @url : String,
                     @to : Int64)
      end
    end
  end
end
