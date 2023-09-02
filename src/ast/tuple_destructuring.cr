module Mint
  class Ast
    class TupleDestructuring < Node
      getter parameters

      def initialize(@parameters : Array(Node),
                     @file : Parser::File,
                     @from : Int64,
                     @to : Int64)
      end

      def exhaustive?
        parameters.all?(Ast::Variable)
      end
    end
  end
end
