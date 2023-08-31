module Mint
  class Ast
    class Access < Node
      getter field, expression, type

      enum Type
        DoubleColon
        Colon
        Dot
      end

      def initialize(@expression : Expression,
                     @field : Variable,
                     @input : Data,
                     @from : Int32,
                     @type : Type,
                     @to : Int32)
      end
    end
  end
end
