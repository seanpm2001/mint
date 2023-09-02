module Mint
  class Ast
    class Function < Node
      getter name, arguments, body, type
      getter comment

      property? keep_name = false

      def initialize(@arguments : Array(Argument),
                     @type : TypeOrVariable?,
                     @comment : Comment?,
                     @name : Variable,
                     @body : Block,
                     @file : Parser::File,
                     @from : Int32,
                     @to : Int32)
      end
    end
  end
end
