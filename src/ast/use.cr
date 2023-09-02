module Mint
  class Ast
    class Use < Node
      getter data, provider, condition

      def initialize(@condition : Node?,
                     @provider : TypeId,
                     @data : Record,
                     @file : Parser::File,
                     @from : Int64,
                     @to : Int64)
      end
    end
  end
end
