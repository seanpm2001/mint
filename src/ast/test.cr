module Mint
  class Ast
    class Test < Node
      getter name, expression

      def initialize(@name : StringLiteral,
                     @expression : Block,
                     @file : Parser::File,
                     @from : Int32,
                     @to : Int32)
      end
    end
  end
end
