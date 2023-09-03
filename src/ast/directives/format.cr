module Mint
  class Ast
    module Directives
      class Format < Node
        getter content

        def initialize(@file : Parser::File,
                       @content : Block,
                       @from : Int64,
                       @to : Int64)
        end
      end
    end
  end
end
