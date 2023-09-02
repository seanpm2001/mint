module Mint
  class Ast
    class HtmlComponent < Node
      getter attributes, children, component, comments, ref, closing_tag_position

      property component_node : Ast::Component? = nil
      property? in_component : Bool = false

      def initialize(@attributes : Array(HtmlAttribute),
                     @closing_tag_position : Int64?,
                     @comments : Array(Comment),
                     @children : Array(Node),
                     @component : TypeId,
                     @ref : Variable?,
                     @file : Parser::File,
                     @from : Int64,
                     @to : Int64)
      end

      def static?
        children.all?(&.static?) && ref.nil? && attributes.all?(&.static?)
      end

      def static_value
        static_hash
      end

      def static_hash
        component.value +
          attributes.join(&.static_value) +
          children.join(&.static_value)
      end
    end
  end
end
