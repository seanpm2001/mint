module Mint
  class Ast
    class RegexpLiteral < Node
      getter value, flags

      def initialize(@value : String,
                     @flags : String,
                     @file : Parser::File,
                     @from : Int64,
                     @to : Int64)
      end

      def static?
        true
      end

      def uniq_flags
        flags.split.uniq!.join
      end

      def static_value
        "/#{value}/#{uniq_flags}"
      end
    end
  end
end
