module Mint
  class Ast
    class HtmlExpression < Node
      getter expressions

      def initialize(@expressions : Array(Node),
                     @file : Parser::File,
                     @from : Int64,
                     @to : Int64)
      end

      def static?
        expressions.all?(&.static?)
      end

      def static_value
        expressions.join(&.static_value)
      end
    end
  end
end
