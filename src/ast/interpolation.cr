module Mint
  class Ast
    class Interpolation < Node
      getter expression

      def initialize(@expression : Expression,
                     @file : Parser::File,
                     @from : Int64,
                     @to : Int64)
      end
    end
  end
end
