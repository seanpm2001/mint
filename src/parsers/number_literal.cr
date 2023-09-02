module Mint
  class Parser
    def number_literal : Ast::NumberLiteral?
      parse do |start_position|
        negation =
          char! '-'

        next if (value = gather { chars &.ascii_number? }.to_s).empty?

        float = false

        if char! '.'
          next error :number_literal_expected_decimal do
            expected "the decimals for a number literal", word
            snippet self
          end unless char.ascii_number?

          float = true

          value += '.' + gather { chars(&.ascii_number?) }.to_s
        end

        value = "-#{value}" if negation

        Ast::NumberLiteral.new(
          from: start_position,
          value: value,
          float: float,
          to: position,
          file: file)
      end
    end
  end
end
