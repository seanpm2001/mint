module Mint
  class Ast
    class EnumId < Node
      getter option, name, expressions

      def initialize(@expressions : Array(Node),
                     @file : Parser::File,
                     @option : TypeId,
                     @name : TypeId?,
                     @from : Int64,
                     @to : Int64)
      end
    end
  end
end
