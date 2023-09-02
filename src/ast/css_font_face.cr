module Mint
  class Ast
    class CssFontFace < Node
      getter definitions

      def initialize(@definitions : Array(Node),
                     @file : Parser::File,
                     @from : Int32,
                     @to : Int32)
      end
    end
  end
end
