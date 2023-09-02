module Mint
  class Ast
    class Test < Node
      getter name, expression

      def initialize(@name : StringLiteral,
                     @expression : Block,
                     @file : Parser::File,
                     @from : Int64,
                     @to : Int64)
      end
    end
  end
end
