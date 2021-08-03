module Mint
  class Parser
    syntax_error EnumDestructuringExpectedDoubleColon
    syntax_error EnumDestructuringExpectedOption
    syntax_error EnumDestructuringExpectedClosingParentheses

    def enum_destructuring
      start do |start_position|
        next unless name = type_id
        next if char.in?('.', '(') # Don't parse module access or call.

        next unless keyword "::"

        option = type_id! EnumDestructuringExpectedOption

        parameters = [] of Ast::Node

        if char! '('
          next unless head = type_variable
          whitespace
          parameters << head

          if char! ','
            whitespace
            parameters.concat list(
              terminator: ')',
              separator: ','
            ) { type_variable }
          end

          whitespace
          char ')', EnumDestructuringExpectedClosingParentheses
        end

        self << Ast::EnumDestructuring.new(
          parameters: parameters,
          from: start_position,
          option: option,
          to: position,
          input: data,
          name: name)
      end
    end
  end
end
