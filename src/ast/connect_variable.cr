module Mint
  class Ast
    class ConnectVariable < Node
      getter variable, name

      def initialize(@variable : Variable,
                     @file : Parser::File,
                     @name : Variable?,
                     @from : Int64,
                     @to : Int64)
      end
    end
  end
end
