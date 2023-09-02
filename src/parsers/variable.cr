module Mint
  class Parser
    INVALID_VARIABLE_NAMES = %w[true false]

    def variable_constant : Ast::Variable?
      parse do |start_position|
        head =
          gather { chars &.ascii_uppercase? }

        tail =
          gather { chars { |char| char.ascii_uppercase? || char.ascii_number? || char == '_' } }

        next unless head

        value = "#{head}#{tail}"

        Ast::Variable.new(
          from: start_position,
          value: value,
          to: position,
          file: file)
      end
    end

    def variable(track = true, extra_chars = [] of Char) : Ast::Variable?
      parse(track: track) do |start_position|
        value = gather do
          next unless char.ascii_lowercase?
          chars { |char| char.ascii_letter? || char.ascii_number? || char.in?(extra_chars) }
        end

        next unless value
        next if value.in?(INVALID_VARIABLE_NAMES)

        Ast::Variable.new(
          from: start_position,
          value: value,
          to: position,
          file: file)
      end
    end
  end
end
