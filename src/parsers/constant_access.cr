module Mint
  class Parser
    def constant_access : Ast::ModuleAccess?
      parse do |start_position|
        name = parse do
          value = type_id
          next unless char! ':'
          value
        end

        next unless name

        variable =
          variable_constant

        next unless variable

        self << Ast::ModuleAccess.new(
          from: start_position,
          variable: variable,
          constant: true,
          to: position,
          input: data,
          name: name)
      end
    end
  end
end
