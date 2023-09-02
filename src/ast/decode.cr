module Mint
  class Ast
    class Decode < Node
      getter expression, type

      def initialize(@expression : Expression?,
                     @file : Parser::File,
                     @from : Int32,
                     @type : Type,
                     @to : Int32)
      end
    end
  end
end
