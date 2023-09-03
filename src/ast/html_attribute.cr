module Mint
  class Ast
    class HtmlAttribute < Node
      getter value, name

      delegate static?, to: @value

      def initialize(@file : Parser::File,
                     @name : Variable,
                     @value : Node,
                     @from : Int64,
                     @to : Int64)
      end

      def static_value : String
        "#{name.value}=#{value.static_value}"
      end
    end
  end
end
