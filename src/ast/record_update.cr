module Mint
  class Ast
    class RecordUpdate < Node
      getter fields, expression

      def initialize(@fields : Array(RecordField),
                     @expression : Ast::Node,
                     @file : Parser::File,
                     @from : Int32,
                     @to : Int32)
      end
    end
  end
end
