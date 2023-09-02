module Mint
  class Ast
    module Directives
      class Documentation < Node
        getter entity

        def initialize(@entity : TypeId,
                       @file : Parser::File,
                       @from : Int64,
                       @to : Int64)
        end
      end
    end
  end
end
