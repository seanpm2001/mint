module Mint
  class Ast
    class State < Node
      getter default, type, name, comment

      def initialize(@default : Expression,
                     @comment : Comment?,
                     @name : Variable,
                     @file : Parser::File,
                     @from : Int64,
                     @type : Type?,
                     @to : Int64)
      end
    end
  end
end
