module Mint
  class TypeChecker
    def check(node : Ast::Argument) : Checkable
      node.default.try { |default| resolve default }

      resolve_type(resolve(node.type)).tap do |item|
        item.label = node.name.try(&.value)
      end
    end
  end
end
