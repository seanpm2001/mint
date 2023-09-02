module Mint
  class Parser
    def type_id(*, track : Bool = true, raise : Bool = false) : Ast::TypeId?
      parse(track: track) do |start_position|
        value = gather do
          return unless char.ascii_uppercase?
          step
          ascii_letters_or_numbers(extra_char: '_')
        end

        return unless value

        parse do
          if char == '.'
            other = parse do
              step
              next_part = type_id(track: false)
              next unless next_part
              next_part
            end

            next unless other

            value += ".#{other.value}"
          end
        end

        Ast::TypeId.new(
          from: start_position,
          value: value,
          to: position,
          file: file)
      end
    end
  end
end
