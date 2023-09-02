module Mint
  class Ast
    class Spread < Node
      getter variable

      def initialize(@variable : Variable,
                     @file : Parser::File,
                     @from : Int32,
                     @to : Int32)
      end
    end
  end
end
