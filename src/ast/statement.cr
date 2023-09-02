module Mint
  class Ast
    class Statement < Node
      getter target, expression, await
      property if_node : Ast::If? = nil

      delegate static?, to: @expression

      def initialize(@expression : Expression,
                     @target : Node?,
                     @await : Bool,
                     @file : Parser::File,
                     @from : Int64,
                     @to : Int64)
      end
    end
  end
end
