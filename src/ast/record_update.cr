module Mint
  class Ast
    class RecordUpdate < Node
      getter fields, expression

      def initialize(@fields : Array(RecordField),
                     @expression : Ast::Node,
                     @file : Parser::File,
                     @from : Int64,
                     @to : Int64)
      end
    end
  end
end
