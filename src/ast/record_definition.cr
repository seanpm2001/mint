module Mint
  class Ast
    class RecordDefinition < Node
      getter fields, name, comment, block_comment

      def initialize(@fields : Array(RecordDefinitionField),
                     @block_comment : Comment?,
                     @file : Parser::File,
                     @comment : Comment?,
                     @name : TypeId,
                     @from : Int64,
                     @to : Int64)
      end
    end
  end
end
