module Mint
  class Ast
    class NumberLiteral < Node
      getter value
      getter? float

      def initialize(@value : String,
                     @file : Parser::File,
                     @float : Bool,
                     @from : Int32,
                     @to : Int32)
      end

      def static?
        true
      end

      def static_value
        value
      end
    end
  end
end
