module Mint
  class Ast
    class MemberAccess < Node
      getter name, type

      def initialize(@file : Parser::File,
                     @name : Variable,
                     @from : Int64,
                     @type : Type,
                     @to : Int64)
      end
    end
  end
end
