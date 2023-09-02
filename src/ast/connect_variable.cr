module Mint
  class Ast
    class ConnectVariable < Node
      getter variable, name

      def initialize(@variable : Variable,
                     @name : Variable?,
                     @file : Parser::File,
                     @from : Int32,
                     @to : Int32)
      end
    end
  end
end
