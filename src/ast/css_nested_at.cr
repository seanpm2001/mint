module Mint
  class Ast
    class CssNestedAt < Node
      getter content, body, name

      def initialize(@body : Array(Node),
                     @content : String,
                     @name : String,
                     @file : Parser::File,
                     @from : Int64,
                     @to : Int64)
      end
    end
  end
end
