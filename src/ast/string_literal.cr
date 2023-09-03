module Mint
  class Ast
    class StringLiteral < Node
      getter? broken
      getter value

      def initialize(@value : Array(String | Interpolation),
                     @file : Parser::File,
                     @broken : Bool,
                     @from : Int64,
                     @to : Int64)
      end

      def string_value
        value.select(String).join
      end

      def static?
        value.all?(String)
      end

      def static_value
        string_value
      end
    end
  end
end
