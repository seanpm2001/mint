module Mint
  class Ast
    class TypeVariant < Node
      getter value, comment, parameters

      def initialize(@parameters : Array(Node) | Array(TypeDefinitionField),
                     @file : Parser::File,
                     @comment : Comment?,
                     @value : TypeId,
                     @from : Int64,
                     @to : Int64)
      end

      def fields : Array(TypeDefinitionField)?
        parameters.select(Ast::TypeDefinitionField) if @parameters.all?(Ast::TypeDefinitionField)
      end
    end
  end
end
