module Mint
  class Ast
    class Comment < Node
      enum Type
        Inline
        Block
      end

      getter value, type

      def initialize(@value : String,
                     @type : Type,
                     @file : Parser::File,
                     @from : Int64,
                     @to : Int64)
      end

      def to_html
        Markd.to_html(value)
      end
    end
  end
end
