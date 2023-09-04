module Mint
  class Ast
    class TypeDefinition < Node
      getter name, fields, parameters, comment

      def initialize(@fields : Array(TypeDefinitionField) | Array(Ast::EnumOption),
                     @parameters : Array(TypeVariable),
                     @file : Parser::File,
                     @comment : Comment?,
                     @name : TypeId,
                     @from : Int64,
                     @to : Int64)
      end
    end
  end
end
