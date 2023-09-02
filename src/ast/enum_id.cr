module Mint
  class Ast
    class EnumId < Node
      getter option, name, expressions

      def initialize(@expressions : Array(Node),
                     @option : TypeId,
                     @name : TypeId?,
                     @file : Parser::File,
                     @from : Int64,
                     @to : Int64)
      end
    end
  end
end
