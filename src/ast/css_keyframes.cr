module Mint
  class Ast
    class CssKeyframes < Node
      getter selectors, name

      def initialize(@selectors : Array(Node),
                     @name : String,
                     @file : Parser::File,
                     @from : Int32,
                     @to : Int32)
      end
    end
  end
end
