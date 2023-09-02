module Mint
  class Ast
    class HtmlFragment < Node
      getter key, children, tag, comments

      def initialize(@comments : Array(Comment),
                     @children : Array(Node),
                     @key : HtmlAttribute?,
                     @file : Parser::File,
                     @from : Int32,
                     @to : Int32)
      end
    end
  end
end
