module Mint
  class Ast
    class For < Node
      getter subject, body, arguments, condition

      def initialize(@arguments : Array(Variable),
                     @subject : Expression,
                     @condition : Block?,
                     @body : Block,
                     @file : Parser::File,
                     @from : Int64,
                     @to : Int64)
      end
    end
  end
end
