module Mint
  class Ast
    class Access < Node
      getter field, expression

      enum Type
        DoubleColon
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
