module Mint
  class Ast
    class Comment < Node
      enum Type
        Inline
        Block
      end

      getter content, type

      def initialize(@file : Parser::File,
                     @content : String,
                     @from : Int64,
                     @type : Type,
                     @to : Int64)
      end

      def to_html
        Markd.to_html(content)
      end
    end
  end
end
