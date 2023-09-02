module Mint
  class Ast
    class EnumOption < Node
      getter value, comment, parameters

      def initialize(@parameters : Array(Node),
                     @comment : Comment?,
                     @value : TypeId,
                     @file : Parser::File,
                     @from : Int64,
                     @to : Int64)
      end
    end
  end
end
