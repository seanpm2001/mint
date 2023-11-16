module Mint
  class Ast
    class Style < Node
      getter name, body, arguments

      property component : Ast::Component? = nil

      def initialize(@arguments : Array(Argument),
                     @file : Parser::File,
                     @body : Array(Node),
                     @name : Variable,
                     @from : Int64,
                     @to : Int64)
      end
    end
  end
end
