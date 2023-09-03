module Mint
  class Ast
    class RecordDefinitionField < Node
      getter key, type, mapping, comment

      def initialize(@mapping : StringLiteral?,
                     @file : Parser::File,
                     @comment : Comment?,
                     @key : Variable,
                     @from : Int64,
                     @type : Type,
                     @to : Int64)
      end
    end
  end
end
