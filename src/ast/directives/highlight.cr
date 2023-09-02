module Mint
  class Ast
    module Directives
      class Highlight < Node
        getter content

        def initialize(@content : Block,
                       @file : Parser::File,
                       @from : Int32,
                       @to : Int32)
        end
      end
    end
  end
end
