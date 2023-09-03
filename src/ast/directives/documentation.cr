module Mint
  class Ast
    module Directives
      class Documentation < Node
        getter entity

        def initialize(@file : Parser::File,
                       @entity : TypeId,
                       @from : Int64,
                       @to : Int64)
        end
      end
    end
  end
end
