module Mint
  class Ast
    class NextCall < Node
      getter data
      property entity : Ast::Node? = nil

      def initialize(@data : Record,
                     @file : Parser::File,
                     @from : Int64,
                     @to : Int64)
      end
    end
  end
end
