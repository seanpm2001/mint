module Mint
  class Ast
    class Use < Node
      getter data, provider, condition

      def initialize(@file : Parser::File,
                     @condition : Node?,
                     @provider : TypeId,
                     @data : Record,
                     @from : Int64,
                     @to : Int64)
      end
    end
  end
end
