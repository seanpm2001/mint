module Mint
  class Ast
    class EnumRecordDefinition < Node
      getter fields

      def initialize(@fields : Array(RecordDefinitionField),
                     @file : Parser::File,
                     @from : Int32,
                     @to : Int32)
      end
    end
  end
end
