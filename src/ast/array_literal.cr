module Mint
  class Ast
    class ArrayLiteral < Node
      getter items, type

      def initialize(@file : Parser::File,
                     @items : Array(Node),
                     @from : Int64,
                     @type : Node?,
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
