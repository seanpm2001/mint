module Mint
  class Ast
    class Style < Node
      getter name, body, arguments

      def initialize(@arguments : Array(Argument),
                     @body : Array(Node),
                     @name : Variable,
                     @file : Parser::File,
                     @from : Int64,
                     @to : Int64)
      end
    end
  end
end
