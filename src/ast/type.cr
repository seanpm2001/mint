module Mint
  class Ast
    class Type < Node
      getter name, parameters

      def initialize(@parameters : Array(Node),
                     @file : Parser::File,
                     @name : Id,
                     @from : Int64,
                     @to : Int64)
      end
    end
  end
end
