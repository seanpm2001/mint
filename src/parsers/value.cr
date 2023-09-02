module Mint
  class Parser
    # A value is basically the smallest possible token, so it matches:
    # - a variable (a)
    # - a type id (Some.Module)
    # - a constant (SOME_CONSTANT)
    def value(subject : Symbol = :all) : Ast::Variable?
      parse do |start_position|
        name =
          case subject
          when :all
            identifier_type || identifier_constant || identifier_variable
          when :constant
            identifier_constant
          end

        next unless name

        Ast::Variable.new(
          from: start_position,
          to: position,
          file: file,
          value: name)
      end
    end
  end
end
