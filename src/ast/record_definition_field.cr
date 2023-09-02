module Mint
  class Ast
    class RecordDefinitionField < Node
      getter key, type, mapping, comment

      def initialize(@mapping : StringLiteral?,
                     @comment : Comment?,
                     @key : Variable,
                     @file : Parser::File,
                     @from : Int64,
                     @type : Type,
                     @to : Int64)
      end
    end
  end
end
