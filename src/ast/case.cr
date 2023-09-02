module Mint
  class Ast
    class Case < Node
      getter branches, condition, comments, await

      def initialize(@branches : Array(CaseBranch),
                     @comments : Array(Comment),
                     @condition : Expression,
                     @await : Bool,
                     @file : Parser::File,
                     @from : Int64,
                     @to : Int64)
      end
    end
  end
end
