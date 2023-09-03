module Mint
  class Ast
    class Access < Node
      getter field, expression, type

      enum Type
        DoubleColon
        Colon
        Dot
      end

      def initialize(@file : Parser::File,
                     @expression : Node,
                     @field : Variable,
                     @from : Int64,
                     @type : Type,
                     @to : Int64)
      end
    end
  end
end
