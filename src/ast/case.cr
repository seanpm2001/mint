module Mint
  class Ast
    class Case < Node
      getter branches, condition, comments, await

      def initialize(@branches : Array(CaseBranch),
                     @comments : Array(Comment),
                     @condition : Expression,
                     @await : Bool,
                     @file : Parser::File,
                     @from : Int32,
                     @to : Int32)
      end
    end
  end
end
