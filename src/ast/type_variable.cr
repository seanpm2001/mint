module Mint
  class Ast
    class TypeVariable < Node
      getter value

      def initialize(@value : String,
                     @file : Parser::File,
                     @from : Int64,
                     @to : Int64)
      end
    end
  end
end
