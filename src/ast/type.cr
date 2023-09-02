module Mint
  class Ast
    class Type < Node
      getter name, parameters

      def initialize(@parameters : Array(TypeOrVariable),
                     @name : TypeId,
                     @file : Parser::File,
                     @from : Int32,
                     @to : Int32)
      end
    end
  end
end
