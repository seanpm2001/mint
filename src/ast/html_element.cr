module Mint
  class Ast
    class HtmlElement < Node
      getter attributes, children, styles, tag, comments, ref
      getter closing_tag_position

      property? in_component : Bool = false

      def initialize(@attributes : Array(HtmlAttribute),
                     @closing_tag_position : Int64?,
                     @comments : Array(Comment),
                     @styles : Array(HtmlStyle),
                     @children : Array(Node),
                     @ref : Variable?,
                     @tag : Variable,
                     @file : Parser::File,
                     @from : Int64,
                     @to : Int64)
      end

      def static?
        children.all?(&.static?) &&
          ref.nil? &&
          attributes.all?(&.static?) &&
          styles.empty?
      end

      def static_value
        tag.value +
          attributes.join(&.static_value) +
          children.join(&.static_value)
      end
    end
  end
end
