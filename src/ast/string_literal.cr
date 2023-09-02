module Mint
  class Ast
    class StringLiteral < Node
      getter value
      getter? broken

      def initialize(@value : Array(String | Interpolation),
                     @broken : Bool,
                     @file : Parser::File,
                     @from : Int64,
                     @to : Int64)
      end

      def string_value
        value
          .select(String)
          .join
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
