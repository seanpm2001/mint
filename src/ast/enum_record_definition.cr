module Mint
  class Ast
    class EnumRecordDefinition < Node
      getter fields

      def initialize(@fields : Array(TypeDefinitionField),
                     @file : Parser::File,
                     @from : Int64,
                     @to : Int64)
      end
    end
  end
end
