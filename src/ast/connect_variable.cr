module Mint
  class Ast
    class ConnectVariable < Node
      getter variable, name

      def initialize(@variable : Variable,
                     @name : Variable?,
                     @file : Parser::File,
                     @from : Int64,
                     @to : Int64)
      end
    end
  end
end
