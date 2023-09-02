module Mint
  class Ast
    class HtmlAttribute < Node
      getter value, name

      delegate static?, to: @value

      def initialize(@value : Node,
                     @name : Variable,
                     @file : Parser::File,
                     @from : Int64,
                     @to : Int64)
      end

      def static_value : String
        "#{name.value}=#{value.static_value}"
      end
    end
  end
end
