module Mint
  class Ast
    class CssDefinition < Node
      getter name, value

      def initialize(@value : Array(String | Node),
                     @name : String,
                     @file : Parser::File,
                     @from : Int64,
                     @to : Int64)
      end
    end
  end
end
