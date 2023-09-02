module Mint
  class Ast
    class EnumOption < Node
      getter value, comment, parameters

      def initialize(@parameters : Array(Node),
                     @comment : Comment?,
                     @value : TypeId,
                     @file : Parser::File,
                     @from : Int32,
                     @to : Int32)
      end
    end
  end
end
