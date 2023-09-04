module Mint
  class Ast
    class TypeVariant < Node
      getter value, comment, parameters

      def initialize(@parameters : Array(Node),
                     @file : Parser::File,
                     @comment : Comment?,
                     @value : TypeId,
                     @from : Int64,
                     @to : Int64)
      end
    end
  end
end
