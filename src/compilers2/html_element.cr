module Mint
  class Compiler2
    def resolve(node : Ast::HtmlElement, imports : Imports) : JsNode
      imports.add({from: runtime, what: runtime_exports[:tag]})

      tag =
        JsString.new(node.tag.value)

      attributes =
        node
          .attributes
          .reject(&.name.value.in?("class", "style"))
          .map { |item| {item.name.value, compile(item, imports).as(JsNode)} }
          .to_h

      children =
        unless node.children.empty?
          items =
            compile node.children, imports

          JsArray.new(items)
        end

      JsCall.new(runtime_exports[:tag], [tag, JsObject.new(attributes), children].compact)
    end
  end
end
