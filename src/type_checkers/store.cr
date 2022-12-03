module Mint
  class TypeChecker
    type_error StoreEntityNameConflict

    def static_type_signature(node : Ast::Store)
      fields = {} of String => Checkable

      node.gets.each do |item|
        fields[item.name.value] = static_type_signature(item)
      end

      node.functions.each do |item|
        fields[item.name.value] = static_type_signature(item)
      end

      node.states.each do |item|
        fields[item.name.value] = static_type_signature(item)
      end

      Record.new(node.name, fields)
    end

    def check(node : Ast::Store) : Checkable
      # Checking for global naming conflict
      check_global_names node.name, node

      # Checking for naming conflicts
      checked =
        {} of String => Ast::Node

      check_names(node.functions, StoreEntityNameConflict, checked)
      check_names(node.states, StoreEntityNameConflict, checked)
      check_names(node.gets, StoreEntityNameConflict, checked)

      # Type checking the entities
      scope node do
        resolve node.constants
        resolve node.functions
        resolve node.states
        resolve node.gets
      end

      NEVER
    end
  end
end
