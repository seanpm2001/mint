module Mint
  class Ast
    class NextCall < Node
      property entity : Ast::Node? = nil
      getter data

      def initialize(@file : Parser::File,
                     @data : Record,
                     @from : Int64,
                     @to : Int64)
      end
    end
  end
end
