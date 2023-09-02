module Mint
  class Ast
    class CssSelector < Node
      getter selectors, body

      def initialize(@selectors : Array(String),
                     @body : Array(Node),
                     @file : Parser::File,
                     @from : Int64,
                     @to : Int64)
      end
    end
  end
end
