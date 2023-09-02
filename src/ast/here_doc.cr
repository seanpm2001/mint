module Mint
  class Ast
    class HereDoc < Node
      getter value, token, modifier

      def initialize(@value : Array(String | Interpolation),
                     @modifier : Char,
                     @token : String,
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
