module Mint
  class Ast
    class CssSelector < Node
      getter selectors, body

      def initialize(@selectors : Array(String),
                     @body : Array(Node),
                     @file : Parser::File,
                     @from : Int32,
                     @to : Int32)
      end
    end
  end
end
