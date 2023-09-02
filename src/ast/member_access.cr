module Mint
  class Ast
    class MemberAccess < Node
      getter name

      def initialize(@name : Variable,
                     @file : Parser::File,
                     @from : Int64,
                     @to : Int64)
      end
    end
  end
end
