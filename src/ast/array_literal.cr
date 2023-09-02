module Mint
  class Ast
    class ArrayLiteral < Node
      getter items, type

      def initialize(@items : Array(Expression),
                     @file : Parser::File,
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
