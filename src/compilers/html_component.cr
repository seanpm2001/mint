module Mint
  class Compiler
    def _compile(node : Ast::HtmlComponent) : String
      if (hash = static_value(node)) && !node.component_node.try(&.async?)
        name =
          static_components_pool.of(hash, nil)

        static_components[name] ||= {compile_html_component(node), node.parent_component}

        "$#{name}()"
      else
        compile_html_component(node)
      end
    end

    def compile_html_component(node : Ast::HtmlComponent) : String
      name =
        js.class_of(lookups[node][0])

      children =
        if node.children.empty?
          nil
        else
          items =
            compile node.children, ", "

          "_array(#{items})"
        end

      attributes =
        node
          .attributes
          .map { |item| resolve(item, false) }
          .reduce({} of String => String) { |memo, item| memo.merge(item) }

      node.ref.try do |ref|
        attributes["ref"] = "(instance) => { this._#{ref.value} = instance }"
      end

      if lookups[node][0].as(Ast::Component).async?
        contents =
          js.object({
            "key" => %("#{Random::Secure.hex}"),
            "x"   => name,
            "p"   => js.object(attributes),
            "c"   => children || "[]",
          })

        "_h(_X, #{contents})"
      else
        contents =
          [name,
           js.object(attributes),
           children]
            .compact
            .reject!(&.empty?)
            .join(", ")

        "_h(#{contents})"
      end
    end
  end
end
