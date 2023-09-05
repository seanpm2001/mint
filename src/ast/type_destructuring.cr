module Mint
  class Ast
    class TypeDestructuring < Node
      getter name, option, parameters

      def initialize(@parameters : Array(Node),
                     @file : Parser::File,
                     @option : Id,
                     @name : Id?,
                     @from : Int64,
                     @to : Int64)
      end
    end
  end
end
