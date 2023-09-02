module Mint
  class Ast
    class HtmlStyle < Node
      getter name, arguments
      property style_node : Ast::Style? = nil

      def initialize(@arguments : Array(Expression),
                     @name : Variable,
                     @file : Parser::File,
                     @from : Int32,
                     @to : Int32)
      end
    end
  end
end
