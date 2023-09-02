module Mint
  class Ast
    class CssKeyframes < Node
      getter selectors, name

      def initialize(@selectors : Array(Node),
                     @name : String,
                     @file : Parser::File,
                     @from : Int64,
                     @to : Int64)
      end
    end
  end
end
