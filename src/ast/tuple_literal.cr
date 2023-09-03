module Mint
  class Ast
    class TupleLiteral < Node
      getter items

      def initialize(@file : Parser::File,
                     @items : Array(Node),
                     @from : Int64,
                     @to : Int64)
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
