module Mint
  class Ast
    class Void < Node
      def initialize(@file : Parser::File,
                     @from : Int32,
                     @to : Int32)
      end
    end
  end
end
