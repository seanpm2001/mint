module Mint
  class Parser
    def connect_variable
      parse do |start_position|
        value = variable(track: false) || variable_constant

        next unless value

        whitespace

        if word! "as"
          whitespace
          next error :connect_variable_expected_as do
            block do
              text "The"
              bold "exposed name"
              text "of a connection"
              bold "must be specified."
            end

            expected "the exposed name", word
            snippet self
          end unless name = variable
        end

        Ast::ConnectVariable.new(
          from: start_position,
          variable: value,
          to: position,
          input: data,
          name: name)
      end
    end
  end
end
