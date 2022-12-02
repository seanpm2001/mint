module Mint
  class Parser
    syntax_error EnumOptionExpectedClosingParentheses

    def enum_option
      start do |start_position|
        comment = self.comment

        next unless value =
                      gather do
                        return unless char.ascii_uppercase?
                        step
                        letters_numbers_or_underscore
                      end
        whitespace

        parameters = [] of Ast::TypeVariable | Ast::Type

        if char! '('
          whitespace

          parameters.concat list(
            terminator: ')',
            separator: ','
          ) { enum_record_definition || type_variable || type }

          whitespace
          char ')', EnumOptionExpectedClosingParentheses
        end

        self << Ast::EnumOption.new(
          parameters: parameters,
          from: start_position,
          comment: comment,
          value: value,
          to: position,
          input: data)
      end
    end
  end
end
