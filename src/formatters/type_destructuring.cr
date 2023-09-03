module Mint
  class Formatter
    def format(node : Ast::TypeDestructuring)
      parameters =
        format node.parameters, ", "

      name =
        "#{format node.name}::" if node.name

      if parameters.empty?
        "#{name}#{format node.option}"
      else
        "#{name}#{format node.option}(#{parameters})"
      end
    end
  end
end
