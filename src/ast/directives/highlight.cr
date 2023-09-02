module Mint
  class Ast
    module Directives
      class Highlight < Node
        getter content

        def initialize(@content : Block,
                       @file : Parser::File,
                       @from : Int64,
                       @to : Int64)
        end
      end
    end
  end
end
