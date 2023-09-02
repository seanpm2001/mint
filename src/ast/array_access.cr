module Mint
  class Ast
    class ArrayAccess < Node
      getter index, lhs

      def initialize(@index : Int64 | Node,
                     @lhs : Node,
                     @file : Parser::File,
                     @from : Int64,
                     @to : Int64)
      end
    end
  end
end
