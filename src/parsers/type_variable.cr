module Mint
  class Parser
    def type_variable : Ast::TypeVariable?
      return unless var = variable

      Ast::TypeVariable.new(
        value: var.value,
        from: var.from,
        file: file,
        to: var.to)
    end
  end
end
