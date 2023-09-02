module Mint
  class Ast
    module Directives
      class Documentation < Node
        getter entity

        def initialize(@entity : TypeId,
                       @file : Parser::File,
                       @from : Int32,
                       @to : Int32)
        end
      end
    end
  end
end
