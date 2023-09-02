module Mint
  class Ast
    class If < Node
      getter condition, branches

      alias Branches = Tuple(Array(CssDefinition), Array(CssDefinition)) |
                       Tuple(Array(CssDefinition), Nil) |
                       Tuple(Array(CssDefinition), If) |
                       Tuple(Block, Block)

      def initialize(@branches : Branches,
                     @condition : Node,
                     @file : Parser::File,
                     @from : Int64,
                     @to : Int64)
      end
    end
  end
end
