module Mint
  class Ast
    class TypeId < Node
      getter value

      def initialize(@value : String,
                     @file : Parser::File,
                     @from : Int32,
                     @to : Int32)
      end
    end
  end
end
