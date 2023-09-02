module Mint
  class Ast
    class Decode < Node
      getter expression, type

      def initialize(@expression : Expression?,
                     @file : Parser::File,
                     @from : Int64,
                     @type : Type,
                     @to : Int64)
      end
    end
  end
end
