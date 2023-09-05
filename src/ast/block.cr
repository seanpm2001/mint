module Mint
  class Ast
    class Block < Node
      getter statements

      def initialize(@statements : Array(Node),
                     @file : Parser::File,
                     @from : Int64,
                     @to : Int64)
      end

      def async?
        statements.select(Ast::Statement).any?(&.await)
      end
    end
  end
end
