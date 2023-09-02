module Mint
  class Ast
    class Constant < Node
      getter name, value, comment

      def initialize(@value : Node,
                     @comment : Comment?,
                     @name : Variable,
                     @file : Parser::File,
                     @from : Int64,
                     @to : Int64)
      end
    end
  end
end
