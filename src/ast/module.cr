module Mint
  class Ast
    class Module < Node
      getter name, functions, comment, comments, constants

      def initialize(@functions : Array(Function),
                     @constants : Array(Constant),
                     @comments : Array(Comment),
                     @comment : Comment?,
                     @name : TypeId,
                     @file : Parser::File,
                     @from : Int32,
                     @to : Int32)
      end
    end
  end
end
