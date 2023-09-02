module Mint
  class Ast
    class Use < Node
      getter data, provider, condition

      def initialize(@condition : Expression?,
                     @provider : TypeId,
                     @data : Record,
                     @file : Parser::File,
                     @from : Int32,
                     @to : Int32)
      end
    end
  end
end
