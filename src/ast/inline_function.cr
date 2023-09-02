module Mint
  class Ast
    class InlineFunction < Node
      getter body, arguments, type

      def initialize(@arguments : Array(Argument),
                     @type : TypeOrVariable?,
                     @body : Block,
                     @file : Parser::File,
                     @from : Int64,
                     @to : Int64)
      end
    end
  end
end
