module Mint
  class Ast
    class RecordField < Node
      getter key, value, comment

      def initialize(@value : Expression,
                     @comment : Comment?,
                     @key : Variable,
                     @file : Parser::File,
                     @from : Int32,
                     @to : Int32)
      end
    end
  end
end
