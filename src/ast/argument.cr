module Mint
  class Ast
    class Argument < Node
      getter type, name, default

      def initialize(@type : TypeOrVariable,
                     @name : Variable,
                     @default : Node?,
                     @file : Parser::File,
                     @from : Int32,
                     @to : Int32)
      end
    end
  end
end
