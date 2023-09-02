module Mint
  class Ast
    class Type < Node
      getter name, parameters

      def initialize(@parameters : Array(TypeOrVariable),
                     @name : TypeId,
                     @file : Parser::File,
                     @from : Int64,
                     @to : Int64)
      end
    end
  end
end
