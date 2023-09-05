module Mint
  class Ast
    class Connect < Node
      getter keys, store

      def initialize(@keys : Array(ConnectVariable),
                     @file : Parser::File,
                     @store : Id,
                     @from : Int64,
                     @to : Int64)
      end
    end
  end
end
