module Mint
  class Ast
    class ArrayDestructuring < Node
      getter items

      def initialize(@file : Parser::File,
                     @items : Array(Node),
                     @from : Int64,
                     @to : Int64)
      end

      # Returns true if the destructuring covers
      # arrays with the given length.
      #
      # [x, ...rest] => 1+
      # [x]          => 1
      # [...rest]    => 0+
      # []           => 0
      def covers?(length)
        if spread?
          length >= (items.size - 1)
        else
          length == items.size
        end
      end

      # Returns whether there are any spreads in the items.
      def spread?
        items.any?(Ast::Spread)
      end

      # Returns whether the destructuring is exhaustive.
      def exhaustive?
        items.all? do |item|
          item.is_a?(Ast::Variable) ||
            item.is_a?(Ast::Spread)
        end && items.any?(Ast::Spread)
      end
    end
  end
end
