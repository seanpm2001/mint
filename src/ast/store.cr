module Mint
  class Ast
    class Store < Node
      getter states, functions, name, gets, comment, comments, constants

      def initialize(@functions : Array(Function),
                     @constants : Array(Constant),
                     @comments : Array(Comment),
                     @states : Array(State),
                     @comment : Comment?,
                     @gets : Array(Get),
                     @name : TypeId,
                     @file : Parser::File,
                     @from : Int64,
                     @to : Int64)
      end

      def owns?(node)
        {functions, constants, states, gets}.any? &.includes?(node)
      end
    end
  end
end
