module Mint
  class Ast
    class InlineFunction < Node
      getter body, arguments, type

      def initialize(@arguments : Array(Argument),
                     @type : TypeOrVariable?,
                     @body : Block,
                     @file : Parser::File,
                     @from : Int32,
                     @to : Int32)
      end
    end
  end
end
