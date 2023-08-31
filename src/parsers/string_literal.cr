module Mint
  class Parser
    def string_literal(with_interpolation : Bool = true) : Ast::StringLiteral?
      parse do |start_position|
        next unless char! '"'

        value =
          many(parse_whitespace: false) do
            if with_interpolation
              raw('"') || interpolation
            else
              raw('"')
            end
          end

        next error :string_expected_closing_quote do
          expected "the closing quoute of a string literal", word
          snippet self
        end unless char! '"'

        broken =
          parse do
            whitespace
            next unless char! '\\'
            true
          end || false

        if broken
          whitespace

          literal =
            string_literal(with_interpolation)

          next error :string_expected_other_string do
            expected "another string literal after a string separator", word
            snippet self
          end unless literal

          value.concat(literal.value)
        end

        # Normalize the value so there are consecutive Strings
        value =
          value.reduce([] of Ast::Interpolation | String) do |memo, item|
            if memo.last?.is_a?(String) && item.is_a?(String)
              memo << (memo.pop.as(String) + item.as(String))
            else
              memo << item
            end

            memo
          end

        Ast::StringLiteral.new(
          from: start_position,
          broken: broken,
          value: value,
          to: position,
          input: data)
      end
    end
  end
end
