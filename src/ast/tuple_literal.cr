module Mint
  class Ast
    class TupleLiteral < Node
      getter items

      def initialize(@items : Array(Expression),
                     @file : Parser::File,
                     @from : Int32,
                     @to : Int32)
      end

      def static?
        items.all?(&.static?)
      end

      def static_value
        values =
          items.join(',', &.static_value)

        "[#{values}]"
      end
    end
  end
end
