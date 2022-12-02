module Mint
  class Formatter
    def format(node : Ast::Value) : String
      node.name
    end
  end
end
