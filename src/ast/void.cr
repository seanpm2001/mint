module Mint
  class Ast
    class Void < Node
      def initialize(@file : Parser::File,
                     @from : Int64,
                     @to : Int64)
      end
    end
  end
end
