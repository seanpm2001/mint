module Mint
  class Ast
    class RecordDefinition < Node
      getter fields, name, comment, block_comment

      def initialize(@fields : Array(RecordDefinitionField),
                     @block_comment : Comment?,
                     @comment : Comment?,
                     @name : TypeId,
                     @file : Parser::File,
                     @from : Int32,
                     @to : Int32)
      end
    end
  end
end
