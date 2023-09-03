module Mint
  class Ast
    class ArrayAccess < Node
      getter index, expression

      def initialize(@index : Int64 | Node,
                     @file : Parser::File,
                     @expression : Node,
                     @from : Int64,
                     @to : Int64)
      end
    end
  end
end
