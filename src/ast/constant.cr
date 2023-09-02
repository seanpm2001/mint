module Mint
  class Ast
    class Constant < Node
      getter name, value, comment

      def initialize(@value : Expression,
                     @comment : Comment?,
                     @name : Variable,
                     @file : Parser::File,
                     @from : Int32,
                     @to : Int32)
      end
    end
  end
end
