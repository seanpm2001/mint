module Mint
  class Ast
    class Get < Node
      getter name, body, type, comment

      def initialize(@type : TypeOrVariable?,
                     @comment : Comment?,
                     @name : Variable,
                     @body : Block,
                     @file : Parser::File,
                     @from : Int64,
                     @to : Int64)
      end
    end
  end
end
