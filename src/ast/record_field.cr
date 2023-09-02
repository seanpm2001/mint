module Mint
  class Ast
    class RecordField < Node
      getter key, value, comment

      def initialize(@value : Expression,
                     @comment : Comment?,
                     @key : Variable,
                     @file : Parser::File,
                     @from : Int64,
                     @to : Int64)
      end
    end
  end
end
