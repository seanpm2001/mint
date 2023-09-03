module Mint
  class Ast
    class TypeId < Node
      getter value

      def initialize(@file : Parser::File,
                     @value : String,
                     @from : Int64,
                     @to : Int64)
      end
    end
  end
end
