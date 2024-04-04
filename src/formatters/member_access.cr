module Mint
  class Formatter
    def format(node : Ast::MemberAccess) : String
      ".#{node.name.value}(#{format(node.type)})"
    end
  end
end
