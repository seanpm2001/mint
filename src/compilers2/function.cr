module Mint
  class Compiler2
    def compile(node : Ast::Function)
      compile node do
        compile(node, contents: nil, args: nil)
      end
    end

    def compile(
      node : Ast::Function, *,
      contents : Compiled | Nil = nil,
      args : Array(Compiled) | Nil = nil,
      skip_const : Bool = false
    ) : Compiled
      items =
        [] of Compiled

      arguments =
        args || compile(node.arguments)

      items << contents if contents
      items << compile(node.body, for_function: true)

      body =
        if async?(node.body)
          js.async_arrow_function(arguments) { js.statements(items) }
        else
          js.arrow_function(arguments) { js.statements(items) }
        end

      if (node.name.value == "render" && node.parent.is_a?(Ast::Component)) ||
         (node.name.value == "update" && node.parent.is_a?(Ast::Provider)) ||
         skip_const
        body
      else
        js.const(node, body)
      end
    end
  end
end
