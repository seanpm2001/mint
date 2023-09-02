module Mint
  class Ast
    class Property < Node
      getter name, default, type, comment

      def initialize(@default : Node?,
                     @comment : Comment?,
                     @name : Variable,
                     @file : Parser::File,
                     @from : Int64,
                     @type : Type?,
                     @to : Int64)
      end
    end
  end
end
