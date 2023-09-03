module Mint
  class Ast
    class Enum < Node
      getter options, name, comments, comment, parameters

      def initialize(@parameters : Array(TypeVariable),
                     @options : Array(EnumOption),
                     @comments : Array(Comment),
                     @file : Parser::File,
                     @comment : Comment?,
                     @name : TypeId,
                     @from : Int64,
                     @to : Int64)
      end
    end
  end
end
