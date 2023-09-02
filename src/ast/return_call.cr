module Mint
  class Ast
    class ReturnCall < Node
      getter expression

      property statement : Ast::Statement? = nil

      def initialize(@expression : Node,
                     @file : Parser::File,
                     @from : Int64,
                     @to : Int64)
      end
    end
  end
end
