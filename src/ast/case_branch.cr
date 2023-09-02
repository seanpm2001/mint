module Mint
  class Ast
    class CaseBranch < Node
      getter match, expression

      def initialize(@expression : Node | Array(CssDefinition),
                     @match : Node?,
                     @file : Parser::File,
                     @from : Int64,
                     @to : Int64)
      end
    end
  end
end
