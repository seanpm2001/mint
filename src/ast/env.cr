module Mint
  class Ast
    class Env < Node
      getter name

      def initialize(@name : String,
                     @file : Parser::File,
                     @from : Int64,
                     @to : Int64)
      end
    end
  end
end
