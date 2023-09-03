module Mint
  class Ast
    class Constant < Node
      getter name, value, comment

      def initialize(@file : Parser::File,
                     @comment : Comment?,
                     @name : Variable,
                     @value : Node,
                     @from : Int64,
                     @to : Int64)
      end
    end
  end
end
