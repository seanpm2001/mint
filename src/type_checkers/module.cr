module Mint
  class TypeChecker
    type_error ModuleEntityNameConflict

    def static_type_signature(node : Ast::Module)
      fields = {} of String => Checkable

      node.functions.each do |item|
        fields[item.name.value] = static_type_signature(item)
      end

      Record.new(node.name, fields)
    end

    def check_all(node : Ast::Module) : Checkable
      resolve node

      scope node do
        resolve node.functions
      end

      NEVER
    end

    def check(node : Ast::Module) : Checkable
      check_names node.functions, ModuleEntityNameConflict
      check_global_names node.name, node

      NEVER
    end
  end
end
