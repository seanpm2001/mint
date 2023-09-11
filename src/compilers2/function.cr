module Mint
  class Compiler2
    def resolve(node : Ast::Function, imports : Imports) : JsNode
      arguments =
        compile node.arguments, imports

      body =
        compile node.body, imports

      JsFunction.new(
        name: (node.name.value if node.keep_name?),
        async: async?(node.body),
        body: [body] of JsNode,
        arguments: arguments)
    end
  end
end
