module Mint
  class Ast
    class Connect < Node
      getter keys, store

      def initialize(@keys : Array(ConnectVariable),
                     @store : TypeId,
                     @file : Parser::File,
                     @from : Int64,
                     @to : Int64)
      end
    end
  end
end
