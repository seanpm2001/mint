module Mint
  class Ast
    class Route < Node
      getter url, expression, arguments

      def initialize(@arguments : Array(Argument),
                     @expression : Block,
                     @file : Parser::File,
                     @from : Int32,
                     @url : String,
                     @to : Int32)
      end
    end
  end
end
